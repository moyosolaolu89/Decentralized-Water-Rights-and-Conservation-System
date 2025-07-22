;; Conservation Incentive Contract
;; Rewards water-saving behaviors and efficient usage

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-USER-NOT-FOUND (err u201))
(define-constant ERR-INSUFFICIENT-FUNDS (err u202))
(define-constant ERR-INVALID-AMOUNT (err u203))
(define-constant ERR-PROGRAM-NOT-FOUND (err u204))

;; Reward tiers
(define-constant BRONZE-THRESHOLD u70)
(define-constant SILVER-THRESHOLD u80)
(define-constant GOLD-THRESHOLD u90)

;; Data Variables
(define-data-var reward-pool uint u1000000) ;; Total rewards available
(define-data-var total-rewards-distributed uint u0)
(define-data-var current-program-id uint u0)

;; Data Maps
(define-map user-rewards principal {
  total-earned: uint,
  current-tier: (string-ascii 10),
  efficiency-score: uint,
  last-reward-block: uint,
  consecutive-months: uint
})

(define-map conservation-programs uint {
  name: (string-ascii 50),
  reward-rate: uint,
  min-efficiency: uint,
  active: bool,
  participants: uint
})

(define-map monthly-achievements {user: principal, month: uint} {
  efficiency: uint,
  reward-earned: uint,
  tier-achieved: (string-ascii 10),
  bonus-multiplier: uint
})

(define-map leaderboard uint {
  user: principal,
  efficiency: uint,
  total-saved: uint,
  rank: uint
})

;; Public Functions

;; Register user for conservation program
(define-public (register-for-program (program-id uint))
  (let (
    (user tx-sender)
    (program (unwrap! (map-get? conservation-programs program-id) ERR-PROGRAM-NOT-FOUND))
  )
    (asserts! (get active program) ERR-PROGRAM-NOT-FOUND)
    (map-set user-rewards user {
      total-earned: u0,
      current-tier: "bronze",
      efficiency-score: u0,
      last-reward-block: block-height,
      consecutive-months: u0
    })
    ;; Update program participant count
    (map-set conservation-programs program-id
      (merge program {participants: (+ (get participants program) u1)}))
    (ok true)))

;; Calculate and distribute rewards based on efficiency
(define-public (calculate-rewards (user principal) (efficiency-score uint) (water-saved uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (let (
      (user-data (unwrap! (map-get? user-rewards user) ERR-USER-NOT-FOUND))
      (tier (determine-tier efficiency-score))
      (base-reward (calculate-base-reward efficiency-score water-saved))
      (bonus-multiplier (get-bonus-multiplier user-data efficiency-score))
      (total-reward (* base-reward bonus-multiplier))
    )
      (asserts! (<= total-reward (var-get reward-pool)) ERR-INSUFFICIENT-FUNDS)

      ;; Update user rewards
      (map-set user-rewards user (merge user-data {
        total-earned: (+ (get total-earned user-data) total-reward),
        current-tier: tier,
        efficiency-score: efficiency-score,
        last-reward-block: block-height,
        consecutive-months: (if (> efficiency-score (get efficiency-score user-data))
                              (+ (get consecutive-months user-data) u1)
                              u0)
      }))

      ;; Record monthly achievement
      (map-set monthly-achievements
        {user: user, month: (/ block-height u4320)} ;; Monthly periods
        {
          efficiency: efficiency-score,
          reward-earned: total-reward,
          tier-achieved: tier,
          bonus-multiplier: bonus-multiplier
        })

      ;; Update totals
      (var-set reward-pool (- (var-get reward-pool) total-reward))
      (var-set total-rewards-distributed (+ (var-get total-rewards-distributed) total-reward))

      (ok total-reward))))

;; Create new conservation program
(define-public (create-program (name (string-ascii 50)) (reward-rate uint) (min-efficiency uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (let ((program-id (+ (var-get current-program-id) u1)))
      (map-set conservation-programs program-id {
        name: name,
        reward-rate: reward-rate,
        min-efficiency: min-efficiency,
        active: true,
        participants: u0
      })
      (var-set current-program-id program-id)
      (ok program-id))))

;; Add funds to reward pool
(define-public (add-to-reward-pool (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)))

;; Claim accumulated rewards
(define-public (claim-rewards)
  (let (
    (user tx-sender)
    (user-data (unwrap! (map-get? user-rewards user) ERR-USER-NOT-FOUND))
    (claimable-amount (get total-earned user-data))
  )
    (asserts! (> claimable-amount u0) ERR-INVALID-AMOUNT)
    ;; Reset earned rewards after claiming
    (map-set user-rewards user (merge user-data {total-earned: u0}))
    (ok claimable-amount)))

;; Read-only Functions

;; Get user reward information
(define-read-only (get-user-rewards (user principal))
  (map-get? user-rewards user))

;; Get conservation program details
(define-read-only (get-program-info (program-id uint))
  (map-get? conservation-programs program-id))

;; Get monthly achievement
(define-read-only (get-monthly-achievement (user principal) (month uint))
  (map-get? monthly-achievements {user: user, month: month}))

;; Get reward pool status
(define-read-only (get-reward-pool-status)
  {
    available: (var-get reward-pool),
    distributed: (var-get total-rewards-distributed),
    programs-active: (var-get current-program-id)
  })

;; Get user's current tier
(define-read-only (get-user-tier (user principal))
  (match (map-get? user-rewards user)
    user-data (ok (get current-tier user-data))
    (err ERR-USER-NOT-FOUND)))

;; Check if user qualifies for rewards
(define-read-only (qualifies-for-rewards (user principal) (efficiency uint))
  (and (>= efficiency BRONZE-THRESHOLD)
       (is-some (map-get? user-rewards user))))

;; Private Functions

;; Determine tier based on efficiency score
(define-private (determine-tier (efficiency uint))
  (if (>= efficiency GOLD-THRESHOLD)
    "gold"
    (if (>= efficiency SILVER-THRESHOLD)
      "silver"
      "bronze")))

;; Calculate base reward amount
(define-private (calculate-base-reward (efficiency uint) (water-saved uint))
  (let ((efficiency-bonus (/ (* efficiency u10) u100)))
    (+ (* water-saved u5) efficiency-bonus)))

;; Get bonus multiplier based on consecutive achievements
(define-private (get-bonus-multiplier (user-data {total-earned: uint, current-tier: (string-ascii 10), efficiency-score: uint, last-reward-block: uint, consecutive-months: uint}) (current-efficiency uint))
  (let ((consecutive (get consecutive-months user-data)))
    (if (>= consecutive u6)
      u3  ;; 3x multiplier for 6+ consecutive months
      (if (>= consecutive u3)
        u2  ;; 2x multiplier for 3+ consecutive months
        u1)))) ;; Base multiplier

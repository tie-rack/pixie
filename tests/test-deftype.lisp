(ns pixie.test.test-deftype
  (require pixie.test :as t))

(deftype Simple [:val])
(deftype Simple2 [val])

(t/deftest test-simple
  (let [o1 (->Simple 1)
        o2 (->Simple 2)]
    (foreach [obj-and-val [[o1 1] [o2 2]]]
             (let [o (first obj-and-val)
                   v (second obj-and-val)]
               (t/assert= (. o :val) v)
               (t/assert= (.val o) v)))))

(deftype Count [:val]
  ICounted
  (-count [self] val))

(deftype Count2 [val]
  ICounted
  (-count [self] val))

(t/deftest test-extend
  (let [o1 (->Count 1)
        o2 (->Count 2)]
    (foreach [obj-and-val [[o1 1] [o2 2]]]
             (let [o (first obj-and-val)
                   v (second obj-and-val)]
               (t/assert= (. o :val) v)
               (t/assert= (.val o) v)
               (t/assert= (-count o) v)
               (t/assert= (count o) v)))))

(deftype Three [:one :two :three]
  Object
  (add [self x & args]
    (apply + x args))
  (one-plus [self x & xs]
    (apply + one x xs))
  ICounted
  (-count [self] (+ one two three)))

(deftype Three2 [one two three]
  Object
  (add [self x & args]
    (apply + x args))
  (one-plus [self x & xs]
    (apply + one x xs))
  ICounted
  (-count [self] (+ one two three)))

(t/deftest test-complex
  (let [o1 (->Three 1 2 3)
        o2 (->Three2 3 4 5)]
    (foreach [obj-and-vals [[o1 1 2 3] [o2 3 4 5]]]
             (let [o (first obj-and-vals)
                   one (second obj-and-vals)
                   two (third obj-and-vals)
                   three (fourth obj-and-vals)]
               (t/assert= (. o :one) one)
               (t/assert= (.one o) one)
               (t/assert= (. o :two) two)
               (t/assert= (.two o) two)
               (t/assert= (. o :three) three)
               (t/assert= (.three o) three)

               (t/assert= (-count o) (+ one two three))
               (t/assert= (count o) (+ one two three))

               (t/assert= (.add o 21 21) 42)
               (t/assert= (.one-plus o 9) (+ one 9))

               ; arity-1 (just the self arg) not supported for now
               (t/assert= (.add o) (. o :add))
               (t/assert= (.one-plus o) (. o :one-plus))))))

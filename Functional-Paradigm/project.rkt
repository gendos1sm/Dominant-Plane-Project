#lang racket

;; Program was tested and files were created with following inputs:
;; (planeRANSAC "filename" 0.98 0.4 0.4)

;; Function that reads point cloud in a file and creates a list of 3D points
(define (readXYZ fileIn)
  (let ((sL (map (lambda s (string-split (car s)))
                 (cdr (file->lines fileIn)))))
    (map (lambda (L)
           (map (lambda (s)
                  (if (eqv? (string->number s) #f)
                      s
                      (string->number s))) L)) sL)))

;; Function to pick 3 random points from a list of points
(define (pickRandomPoints points)
  (define (already-present? point already-picked)
    (cond ((null? already-picked) #f)
          ((equal? point (car already-picked)) #t)
          (#t (already-present? point (cdr already-picked)))))
  
 ;; Filters already picked points   
  (define (pick-a-point already-picked points)
    (let ((point (list-ref points (random (length points)))))
      (cond ((= 3 (length already-picked)) already-picked)
            ((already-present? point already-picked)
             (pick-a-point already-picked points))
            (#t (pick-a-point (cons point already-picked) points)))))
  (pick-a-point '() points))
          
  ;(list (list-ref points (random (length points)))
  ;      (list-ref points (random (length points)))
  ;      (list-ref points (random (length points)))))

;; Function that computes a plane equation from 3 points
(define (plane P1 P2 P3)
  (let* ((x1 (car P1)) (y1 (cadr P1)) (z1 (caddr P1))
         (x2 (car P2)) (y2 (cadr P2)) (z2 (caddr P2))
         (x3 (car P3)) (y3 (cadr P3)) (z3 (caddr P3))
         (a1 (- x2 x1))
         (b1 (- y2 y1))
         (c1 (- z2 z1))
         (a2 (- x3 x1))
         (b2 (- y3 y1))
         (c2 (- z3 z1))
         (a (- (* b1 c2) (* b2 c1)))
         (b (- (* a2 c1) (* a1 c2)))
         (c (- (* a1 b2) (* b1 a2)))
         (d (* -1 (+ (* a x1) (* b y1) (* c z1)))))
         ;(a (- (* y1 (- z2 z3)) (* y2 (- z1 z3)) (* y3 (- z1 z2))))
         ;(b (- (* z1 (- x2 x3)) (* z2 (- x1 x3)) (* z3 (- x1 x2))))
         ;(c (- (* x1 (- y2 y3)) (* x2 (- y1 y3)) (* x3 (- y1 y2))))
         ;(d (+ (* x1 (+ (* y2 z3) (- y3 z2))) (* x2 (+ (* y3 z1) (- y1 z3))) (* x3 (+ (* y1 z2) (- y2 z1))))))
    `(,a ,b ,c ,d)))



;; Function that computes the number of iterations
(define (ransacNumberOfIteration confidence percentage)
  (let* ((op1 (log (- 1.0 confidence)))
         (op2 (log (- 1.0 (expt percentage 3))))
         (numIterations (round (/ op1 op2))))
    (exact->inexact numIterations)))

(define (get-plane points)
  (let ((random-points (pickRandomPoints points)))
    (apply plane random-points)))


(define (diff-point plane point)
  (let ((a (list-ref plane 0))
        (b (list-ref plane 1))
        (c (list-ref plane 2))
        (d (list-ref plane 3))
        (x (list-ref point 0))
        (y (list-ref point 1))
        (z (list-ref point 2)))
    (/ (abs (+ (* a x) (* b y) (* c z) d))
       (sqrt (+ (* a a) (* b b) (* c c))))))
    ;(- (+ (* a x) (* b y) (* c z)) d)))

(define (point-in-plane? plane point eps)
  (< (abs (diff-point plane point)) eps))

(define (support plane points eps)
  (cons (foldl (lambda (point num)
                 (if (point-in-plane? plane point eps)
                     (+ num 1)
                     num))
               0 points)
        plane))

;;(define test-points (readXYZ "testdata.xyz"))

(define (equal-plane? plane1 plane2 eps)
  (andmap (lambda (p1 p2)
              (< (abs (- p1 p2)) eps))
            plane1 plane1))

(define (dominantPlane points k eps)
  (find-plane k #f points eps))

(define (find-plane iter-num current-result points eps)
  (if (= iter-num 0)
      current-result
      (let* ((plane (apply plane (pickRandomPoints points)))
             (result (support plane points eps)))
        (cond ((not current-result)
               (find-plane iter-num result points eps))
              ((equal-plane? (cdr current-result) plane eps)
               (find-plane (- iter-num 1) current-result points eps))
              ((< (car current-result) (car result))
               (find-plane (- iter-num 1) result points eps))
              (#t (find-plane (- iter-num 1) current-result points eps))))))

(define (RANSAC filename confidence percentage eps)
  (let* ((points (readXYZ filename))
         (iter-num (ransacNumberOfIteration confidence percentage))
         (p (apply plane (pickRandomPoints points))))
    (dominantPlane points iter-num eps)))

(define (planeRANSAC filename confidence percentage eps)
  (let* ((output-filename "output.txt")
         (points (readXYZ filename))
         (result (RANSAC filename confidence percentage eps))
         (matching-points (filter (lambda (point)
                                    (point-in-plane? (cdr result) point eps))
                                  points)))
    (display-to-file "x y z" output-filename #:exists 'append)
    (display-to-file "\n" output-filename #:exists 'append)
    (map (lambda (p)
           (display-to-file (car p) output-filename #:exists 'append)
           (display-to-file " " output-filename #:exists 'append)
           (display-to-file (cadr p) output-filename #:exists 'append)
           (display-to-file " " output-filename #:exists 'append)
           (display-to-file (caddr p) output-filename #:exists 'append)
           (display-to-file "\n" output-filename #:exists 'append))
         matching-points)
    #t))
    

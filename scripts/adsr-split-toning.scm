; Split-toning effect
;
; Copyright (C) 2011 AdSR
;
; Version 1.3
; Original author: AdSR
; (C) 2011
;
; Tags: photo, split-toning
;
; See: http://gimp-tutorials.net/GIMP-split-toning-tutorial

(define (adsr-split-toning image drawables highlights hi-opacity shadows
                           desaturate-orig)

  (script-fu-use-v3)
  (gimp-image-undo-group-start image)
  
  (define layer (vector-ref drawables 0))

  (define (add-masked-layer image layer name tint invert-mask)
    (let* ((tint-layer (gimp-layer-new image "Tint"
                                            (gimp-image-get-width image)
                                            (gimp-image-get-height image)
                                            (gimp-drawable-type layer)
                                            100 LAYER-MODE-OVERLAY)))

      (gimp-item-set-name layer name)
      (gimp-image-insert-layer image layer -1)
      (gimp-drawable-desaturate layer DESATURATE-LIGHTNESS)

      (gimp-image-set-selected-layers image (vector layer))
      (gimp-image-insert-layer image tint-layer -1)

      (gimp-context-set-foreground tint)
	  (define FOREGROUND-FILL 0)
      (gimp-drawable-fill tint-layer FOREGROUND-FILL)
	  (gimp-image-set-selected-layers image (vector tint-layer))
      (set! layer
        (gimp-image-merge-down image tint-layer CLIP-TO-IMAGE))
      (define GIMP_ADD_MASK_COPY 5)
      (let* ((mask (gimp-layer-create-mask layer GIMP_ADD_MASK_COPY)))
        (gimp-layer-add-mask layer mask)
        (if invert-mask
          (gimp-drawable-invert mask)))

      layer))

  (if (<> (gimp-image-get-base-type image) RGB)
    (gimp-image-convert-rgb image))

  (if (= desaturate-orig TRUE)
    (gimp-drawable-desaturate layer DESATURATE-LIGHTNESS))

  (let* ((hi-layer (gimp-layer-copy layer #t))
         (lo-layer (gimp-layer-copy layer #t))
         (original-fg (gimp-context-get-foreground)))

    (add-masked-layer image lo-layer "Shadows" shadows #t)
    (gimp-layer-set-opacity
      (add-masked-layer image hi-layer "Highlights" highlights #f)
      hi-opacity)
    
    (gimp-context-set-foreground original-fg))

  (gimp-image-undo-group-end image)
  (gimp-displays-flush))
(script-fu-register-filter "adsr-split-toning"
                    _"Split-Toning..."
                    _"Rore's split-toning effect."
                    "AdSR (adsr at poczta onet pl)"
                    "Copyright (C) 2011 AdSR"
                    "2011-07-31"
                    "*"
					SF-ONE-DRAWABLE 
                    SF-COLOR      _"Highlights" '(255 198 00)
                    SF-ADJUSTMENT _"Highlights opacity" '(75 0 100 1 5 0
                                                          SF-SLIDER)
                    SF-COLOR      _"Shadows" '(43 198 255)
                    SF-TOGGLE     _"Desaturate original" FALSE)

(script-fu-menu-register "adsr-split-toning" _"<Image>/Filters/Artistic")

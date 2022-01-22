globals
[
  num-consume-bottles
  num-collection-bottles
  num-return-bottles-families
  num-return-bottles-couples
  num-return-bottles-singles
  fam-consume
  cpl-consume
  sgl-consume
  rate-returning
  rate-recycling
  total-budget-for-policy
  recycling-campaign-investment
  policy-of-recycling-campaign ; involve small bottles or not?


] ;there is a maximum quantity of bottles that can be consumed in the market,
;set this in the global environment, so we can discard the producer agent,
;the consumption of bottles in total from 3 breeds cannot exceed the maximum numbers of bottles

breed [families family]
breed [couples couple]
breed [singles single]
breed [municipalities municipality]
breed [recycling-companies recycling-company]
breed [collection-points collection-point]


families-own
[
  f-base-knowledge-level
  f-base-knowledge                 ; the amount of knowledge a turtle has of small bottle recycling
  f-knowledge-increase-perc
  f-increase-knowledge             ; increased knowledhe of small bottle recycling of a turtle
  f-acceptance-of-campaign         ; whether or not accept knowledge of recycling campaign
  f-consumption-small-bottles       ; how many small bottles a turtle consumes
  f-small-bottle-return-perc       ; percentage of small bottles returned by turtle
  f-increase-return-perc           ; percentage that increases depending on the turtle's knowledge
]


couples-own
[
  c-base-knowledge-level
  c-base-knowledge                 ; the amount of knowledge a turtle has of small bottle recycling
  c-knowledge-increase-perc
  c-increase-knowledge             ; increased knowledhe of small bottle recycling of a turtle
  c-acceptance-of-campaign         ; whether or not accept knowledge of recycling campaign
  c-consumption-small-bottles       ; how many small bottles a turtle consumes
  c-small-bottle-return-perc       ; percentage of small bottles returned by turtle
  c-increase-return-perc           ; percentage that increases depending on the turtle's knowledge
]

singles-own
[
  s-base-knowledge-level
  s-base-knowledge                 ; the amount of knowledge a turtle has of small bottle recycling
  s-knowledge-increase-perc
  s-increase-knowledge             ; increased knowledhe of small bottle recycling of a turtle
  s-acceptance-of-campaign         ; whether or not accept knowledge of recycling campaign
  s-consumption-small-bottles       ; how many small bottles a turtle consumes
  s-small-bottle-return-perc       ; percentage of small bottles returned by turtle
  s-increase-return-perc           ; percentage that increases depending on the turtle's knowledge
]


;municipalities-own[
 ; total-budget-for-policy
  ;recycling-campaign-investment
  ;policy-of-recycling-campaign ; involve small bottles or not?
;]

recycling-companies-own[
  recycling-capacity; how many bottles can a recycling company recieve
  recycling-investment
  num-recieve-bottles
  num-recycle-bottles
  sum-recycle
  total-recycle

]

collection-points-own[
  collection-capacity; how many bottles can a collection point collect
  collection-investment
  num-return-bottles
  sum-collection
  total-collection
]

;;;
;;; SETUP AND HELPERS
;;;

to setup
  clear-all
  ;; set global variables to appropriate consumer types
   create-families population * initial-perc-families [
    set f-base-knowledge-level random 2 ; randomization of yes/no of acceptance,
    if f-base-knowledge-level = 0 [
      set f-base-knowledge 0.5
    ]
    if f-base-knowledge-level = 1 [
      set f-base-knowledge 0.9
    ]
    set f-acceptance-of-campaign random 2
    ;set accessibility-collection-point [0 1]
    set shape "person"
    set size 1.5
    move-to one-of patches
    set color green
  ]
   create-couples population * initial-perc-couples [
    set c-base-knowledge-level random 2 ; randomization of high/ low knowledge,
    if c-base-knowledge-level = 0 [
      set c-base-knowledge 0.5
    ]
    if c-base-knowledge-level = 1 [
      set c-base-knowledge 0.9
    ]
    set c-acceptance-of-campaign random 2; randomization of yes/no of acceptance
    ;set accessibility-collection-point [0 1]
    set shape "person"
    set size 1.2
    move-to one-of patches
    set color blue
  ]
   create-singles population * initial-perc-singles [
    set s-base-knowledge random random 2  ; randomization of high/ low knowledge,
    if s-base-knowledge-level = 0 [
      set s-base-knowledge 0.5
    ]
    if s-base-knowledge-level = 1 [
      set s-base-knowledge 0.9
    ]
    set s-acceptance-of-campaign random 2; randomization of yes/no of acceptance
    ;set accessibility-collection-point [0 1]
    set shape "person"
    set size 1
    move-to one-of patches
    set color red
  ]

  create-recycling-companies initial-num-recycling-companies[
    set sum-recycle [0]
    set recycling-capacity R-capacity ; R-capacity is a fixed number
    set shape  "house"
    set color white
    set size 3  ; easier to see
  ]

  create-collection-points initial-num-collection-points[
    set sum-collection [0]
    set collection-capacity C-capacity ; C-capacity is a fixed number
    set shape  "house"
    set color yellow
    set size 2  ; easier to see
  ]

  set fam-consume [0]
  set cpl-consume [0]
  set sgl-consume [0]


  layout-circle (sort-on [who] recycling-companies) 5
  layout-circle (sort-on [who] collection-points) 12

  if model-version = "yes-policy" [

      set policy-of-recycling-campaign  "yes"
      set total-budget-for-policy total-budget
      set recycling-campaign-investment total-budget * fraction-of-campaign


    ask recycling-companies [
      set recycling-investment total-budget * fraction-of-technology
      set recycling-capacity R-capacity-incease
      ;let recycling-changing-ratio [5 1000]
    ]

    ask collection-points [
      set collection-investment total-budget * fraction-of-collection
      set collection-capacity C-capacity-incease
      ;let collection-changing-ratio [5 1000]
    ]
  ]

  if model-version = "no-policy" [

    set policy-of-recycling-campaign  "no"

  ]

  ;; call other procedures to set up various parts of the world
  ;setup-patches
  ;setup-recycling-rate
  ;update-total-recycled

  reset-ticks
end

to-report R-capacity-incease []
  report R-capacity + recycling-investment * recycling-changing-ratio;(1 euro = 0.1 bottles) ;recycling-changing-rate will be a fixed number
end

to-report C-capacity-incease []
  report C-capacity + collection-investment * collection-changing-ratio ;collection-changing-rate will be a fixed number
end



to go
  ; if not any? turtles [ stop ]
    ask families [
      move
      consume-bottles
    ]

    ask couples [
      move
      consume-bottles
    ]

    ask singles [
      move
      consume-bottles
      ]


    ask collection-points [
      collect-bottles
      calculate-collection-bottles
      calculate-rate-returning
      generateOutput
      calculate-total-collection-bottles
    ]

  tick


  if ticks mod 4 = 0 [
    ask recycling-companies [
      recycle-bottles
      calculate-recycle-bottles
      calculate-rate-recycling
      calculate-total-recycling-bottles
    ]
  ]

  if ticks mod 52 = 0 [
    reset-ticks
  ]


update-plots; auto-plot-on ????
  display-labels

end

to-report info ; format this however you want:
  report [ (word who ": " num-return-bottles ", ") ] of collection-points
end




to move
  rt random 50 ;turn right randomly
  lt random 50 ;turn left randomly
  fd 1
end

to consume-bottles
  ask families [
    set f-consumption-small-bottles random-float 10; randomization of small bottle consumptiom, number need to be reset for data analysis
    ;set fam-consume lput f-consumption-small-bottles fam-consume
    ;print fam-consume
  ]

  ask couples [
    set c-consumption-small-bottles random-float 8; randomization of small bottle consumptiom, number need to be reset for data analysis
    set cpl-consume lput c-consumption-small-bottles cpl-consume
  ]

  ask singles [
    set s-consumption-small-bottles random-float 10; randomization of small bottle consumptiom, number need to be reset for data analysis
    set sgl-consume lput s-consumption-small-bottles sgl-consume
  ]
end

to collect-bottles  ; wolf procedure
  ask families[
    calculate-return-bottles-families
  ]

  ask couples [
    calculate-return-bottles-couples
  ]

  ask singles [
    calculate-return-bottles-singles
  ]

end


to calculate-return-bottles-families

    if policy-of-recycling-campaign = "yes"[
      ask families[
        if f-acceptance-of-campaign = 1 [ ;yes
          if f-base-knowledge-level = 0 [ ;low
            set f-knowledge-increase-perc random-float 0.4 + 0.1
            set f-increase-knowledge f-base-knowledge * ( 1 + f-knowledge-increase-perc )
          ]
          if f-base-knowledge-level = 1 [ ;high
            set f-knowledge-increase-perc random-float 0.05
            set f-increase-knowledge f-base-knowledge * ( 1 + f-knowledge-increase-perc )
          ]
        ]

       if f-acceptance-of-campaign = 0 [ ;no
       set f-increase-knowledge f-base-knowledge
      ]

    set num-return-bottles-families sum [f-consumption-small-bottles * f-increase-knowledge ] of families
      ]
   ]
  if policy-of-recycling-campaign = "no"[
    ask families[
        set num-return-bottles-families sum [ f-consumption-small-bottles * f-base-knowledge ] of families
      ]
    ]


end

to calculate-return-bottles-couples

    if policy-of-recycling-campaign = "yes"[
      ask couples [
        if c-acceptance-of-campaign = 1 [
          if c-base-knowledge-level = 0 [
            set c-knowledge-increase-perc random-float 0.4
            set c-increase-knowledge c-base-knowledge * ( 1 + c-knowledge-increase-perc )
            ]
          if c-base-knowledge-level = 1 [
            set c-knowledge-increase-perc random-float 0.05
            set c-increase-knowledge c-base-knowledge * ( 1 + c-knowledge-increase-perc )
            ]
        ]

       if c-acceptance-of-campaign = 0 [
          set c-increase-knowledge c-base-knowledge
          ]
       set num-return-bottles-couples  c-consumption-small-bottles * c-increase-knowledge
      ]
    ]
    if policy-of-recycling-campaign = "no"[
       ask couples [
          set num-return-bottles-couples sum [ c-consumption-small-bottles * c-base-knowledge ] of couples
        ]
     ]

end

to calculate-return-bottles-singles

    if policy-of-recycling-campaign = "yes"[
      ask singles [
        if s-acceptance-of-campaign = 1 [
          if s-base-knowledge-level = 0 [
            set s-knowledge-increase-perc random-float 0.4
            set s-increase-knowledge s-base-knowledge * ( 1 + s-knowledge-increase-perc )
            ]
          if s-base-knowledge-level = 1 [
            set s-knowledge-increase-perc random-float 0.05
            set s-increase-knowledge s-base-knowledge * ( 1 + s-knowledge-increase-perc )
            ]
        ]


       if s-acceptance-of-campaign = "no" [
          set s-increase-knowledge s-base-knowledge
          ]
       set num-return-bottles-singles sum [ s-consumption-small-bottles * s-increase-knowledge ] of singles
      ]
    if policy-of-recycling-campaign = "no"[
       ask singles[
          set num-return-bottles-singles sum [ s-consumption-small-bottles * s-base-knowledge ] of singles
        ]
      ]
    ]


end



to calculate-collection-bottles
  ask collection-points [
    set num-return-bottles num-return-bottles-families + num-return-bottles-couples + num-return-bottles-singles

      if num-return-bottles >= collection-capacity [
        set num-collection-bottles collection-capacity
        user-message "reached collection capacity"
        ]
      if num-return-bottles < collection-capacity [
        set num-collection-bottles num-return-bottles
        ]
    set sum-collection lput num-collection-bottles sum-collection
  ]
end


to recycle-bottles
  ask recycling-companies [
    set num-recieve-bottles num-collection-bottles * (1 - loss-rate) ;manually setup loss-rate, loss during transportation and unexpected accidents
  ]
end


to calculate-recycle-bottles
  ask recycling-companies [
    if num-recieve-bottles >= recycling-capacity [
      set num-recycle-bottles recycling-capacity
      user-message "reached recycling capacity"
       ]
    if num-recieve-bottles < recycling-capacity [
      set num-recycle-bottles num-recieve-bottles
      ]
    set sum-recycle lput num-recycle-bottles sum-recycle
  ]
end

to calculate-total-collection-bottles
  ask collection-points [
    set total-collection sum sum-collection

  ]
end

to calculate-total-recycling-bottles
  ask recycling-companies [
    set total-recycle sum sum-recycle
    print total-recycle
  ]
end

to calculate-rate-returning
  set num-consume-bottles sum fam-consume + sum cpl-consume + sum sgl-consume
  if num-consume-bottles = 0 [
      set rate-returning 0
       ]
  if num-consume-bottles > 0 and num-consume-bottles <= max-bottles [
      set rate-returning num-return-bottles / num-consume-bottles
      ]

  if num-consume-bottles > max-bottles [
    user-message "consumption exceedes the market capacity" stop
  ]
end


to calculate-rate-recycling

    if num-recycle-bottles = 0 [
      set rate-recycling 0
      ]
    if num-recycle-bottles > 0 [
      set rate-recycling total-recycle / num-consume-bottles
      ]
  print rate-recycling
end

to display-labels
  ask turtles [ set label "" ]
  if show-bottles? [
    ask families [ set label num-return-bottles-couples ]
    ask couples [ set label num-return-bottles-couples ]
    ask singles [ set label num-return-bottles-singles ]
    ask collection-points [ set label num-collection-bottles ]
    ask recycling-companies [ set label total-recycle ]
  ]

end


to generateOutput
  file-open "output.txt"
  file-print fam-consume
end
@#$#@#$#@
GRAPHICS-WINDOW
387
10
893
517
-1
-1
15.1
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
18
84
245
117
initial-perc-families
initial-perc-families
0
1
0.3
0.01
1
*100 %
HORIZONTAL

SLIDER
18
130
245
163
initial-perc-couples
initial-perc-couples
0
1
0.3
0.01
1
*100 %
HORIZONTAL

SLIDER
18
176
245
209
initial-perc-singles
initial-perc-singles
0
1
0.4
0.01
1
*100 %
HORIZONTAL

SLIDER
20
237
187
270
initial-num-recycling-companies
initial-num-recycling-companies
1
5
2.0
1
1
company
HORIZONTAL

SLIDER
201
237
370
270
R-capacity
R-capacity
1
1000000
558001.0
1000
1
bottles
HORIZONTAL

SLIDER
19
365
188
398
initial-num-collection-points
initial-num-collection-points
1
9
8.0
1
1
point
HORIZONTAL

SLIDER
201
365
372
398
C-capacity
C-capacity
1
1000000
814101.0
100
1
bottles
HORIZONTAL

CHOOSER
18
11
370
56
model-version
model-version
"yes-policy" "no-policy"
0

INPUTBOX
256
479
372
599
total-budget
100.0
1
0
Number

SLIDER
19
479
244
512
fraction-of-campaign
fraction-of-campaign
0
1.00
0.1
0.01
1
*100 %
HORIZONTAL

SLIDER
19
566
246
599
fraction-of-technology
fraction-of-technology
0
1.00
0.11
0.01
1
*100 %
HORIZONTAL

SLIDER
19
523
245
556
fraction-of-collection
fraction-of-collection
0
1.00
0.41
0.01
1
*100 %
HORIZONTAL

INPUTBOX
201
275
371
335
recycling-changing-ratio
1.0
1
0
Number

INPUTBOX
201
405
372
465
collection-changing-ratio
2.0
1
0
Number

BUTTON
515
543
615
593
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
649
542
744
593
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
906
29
1325
238
Overview
steps
Num-bottles
0.0
52.0
0.0
10000.0
true
true
"" ""
PENS
"total-recycle" 1.0 0 -16777216 true "" "ask recycling-companies [plot total-recycle]"
"total-conusmption/100" 1.0 0 -6995700 true "" "plot num-consume-bottles / 100"

INPUTBOX
20
275
188
335
loss-rate
0.0
1
0
Number

INPUTBOX
252
149
369
209
population
10.0
1
0
Number

INPUTBOX
251
85
369
145
max-bottles
1000000.0
1
0
Number

TEXTBOX
20
62
170
80
Consumers SetUp
14
0.0
1

TEXTBOX
20
217
242
251
Recycling Companies SetUp
14
0.0
1

TEXTBOX
21
344
281
372
Collection Points SetUp
14
0.0
1

TEXTBOX
22
459
172
477
Budget SetUp
14
0.0
1

TEXTBOX
907
10
1057
28
Plots
14
0.0
1

MONITOR
915
291
1080
336
num-collection-bottles
map info sort collection-points
20
1
11

SWITCH
931
382
1079
415
show-bottles?
show-bottles?
0
1
-1000

PLOT
1121
312
1321
462
total collection
steps
num-bottles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total-collection" 1.0 0 -16777216 true "" "ask collection-points [plot total-collection]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

single
true
0
Circle -955883 true false 65 65 170

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

;;
;; https://glenng.mindmodeling.org/pubs/journalarticles/2018-fisher_houpt_gunzelmann.pdf - A Comparison of Approximations for Base-Level Activation in ACT-R
; 4/2 - added degree centrality, closeness, small world // small-world
; 4/3 started working on changing number of agents, tracking agents who changed randomly
; 4/14 - try to make graph reporters run only once
; 4/16
;   - How does size effect outcome? (100, 500, 1000, 10000)
;   - How does seeding method affect outcome? (only do degree for now)
;   - How does threshold heterogeneity  affect outcome? (0, +-.2, +-.4, +-.6)
;   - Seed budget 1,10,20
; likelihoods 0.01, .5
; 4/21 get rid of c
; 4/24 NOTE: "citations" network is actually a collaboration network (Condensed Matter), changed "citations" to "collaborations" in presentation


extensions [nw]

globals [
  seedlist ; seedlist used for non-generated networks - PA***
  global-clustering-coefficient ; not used - PA
  seeded-clustering-coefficient ; not used - PA
  avg-seeded-clustering-coefficient ; not used - PA
]

turtles-own [
  adopted?    ;; whether or not the agent has adopted the product
  random? ;; whether or not adoption was forced randomly PA *****
  seeded? ;; whether or not node was seeded with innovation PA *****
  coef_innov ;; Bass model PA *****
  coef_imit ;; Bass Model PA *****
  node_id ;; node_id of label, using this to get lables from populating in spring layout PA *****
]

to setup
  clear-all
  create-network
  seed
  set-agent-dispositions
;  generate-network-metrics ; PA - can't get this to work, reports 0 as value
  reset-ticks
end

to go
  if all? turtles [ adopted? ] [ stop ]
  ask turtles with [ not adopted? ] [ decide-to-adopt ]
  ask turtles [ update-color ]
  tick
end

;; the decision rule to adopt which is based on the Bass model of diffusion
to decide-to-adopt
  ifelse random-float 1.0 < coef_innov [ ;PA -***
    set adopted? true
    set random? true
  ] [
    if any? link-neighbors [
      let neighbors-adoption count link-neighbors with [ adopted? ] / count link-neighbors
      if random-float 1.0 < coef_imit * neighbors-adoption [ ;; PA - ***
        set adopted? true
      ]
    ]
  ]
end

;Threshold-Deviation

to set-agent-dispositions ;; PA
  if Threshold-Deviation = 0 [
    ask turtles [
    set coef_innov Base_Likelihood_to_Innovate
    set coef_imit Base_Likelihood_to_Imitate
  ]]
    if Threshold-Deviation != 0 [
    ask turtles [
    set coef_innov ((1 - Threshold-Deviation) + random-float (Threshold-Deviation * 2)) * Base_Likelihood_to_Innovate
;     set coef_innov ((Threshold-Deviation) + random-float (Threshold-Deviation)) * Base_Likelihood_to_Innovate ; wrong base
;      show ((1 - Threshold-Deviation) + random-float (Threshold-Deviation))
;      show ((1 - Threshold-Deviation) + random-float (Threshold-Deviation * 2)) ; this seems to work
;      show (0.8 + random-float 0.4)
      ; if threshold deviation = +- 20%, want to do random value starting at .8 of likelihood to 1.2 of likelihood/ if .2, .8 to 1.2, if .4, .6  to 1.4, if .6 = .4 to 1.6,
    set coef_imit ((1 - Threshold-Deviation) + random-float (Threshold-Deviation * 2)) * Base_Likelihood_to_Imitate
  ]]
end
;set threshold (0.8 + random-float 0.4) * overcrowding-threshold

;; seed the population with users who have already been given the product
;;  you can either seed randomly or use betweenness centrality
to seed

  if seeding-method = "random" [
      ask n-of budget turtles [
        set adopted? true
        set seeded? true ;; -PA *****
        update-color
      ]
  ]
  if network-type = "random" or network-type = "preferential-attachment" or network-type = "small-world" or network-type = "padgettm"  or network-type = "padgettmb"[

    if seeding-method = "betweenness" [
      if Seed-Order = "Descending" [
        ask max-n-of budget turtles [ nw:betweenness-centrality ] [
          set adopted? true
          set seeded? true ;; -PA *****
          update-color
      ]]
      if Seed-Order = "Ascending" [
        ask min-n-of budget turtles [ nw:betweenness-centrality ] [
          set adopted? true
          set seeded? true ;; -PA *****
          update-color
        ]]
        ]
    if seeding-method = "closeness" [
      if Seed-Order = "Descending" [
        ask max-n-of budget turtles [ nw:closeness-centrality ] [
          set adopted? true
          set seeded? true ;; -PA *****
          update-color
      ]]
      if Seed-Order = "Ascending" [
        ask min-n-of budget turtles [ nw:closeness-centrality ] [
          set adopted? true
          set seeded? true ;; -PA *****
          update-color
        ]]
        ]

        ;nw:closeness-centrality
        ;The closeness centrality of a turtle is defined as the inverse of the average of it’s distances to all other turtles. (Some people use the sum of distances instead of the average, but the extension uses the average.)
        ;
        ;Note that this primitive reports the intra-component closeness of a turtle, that is, it takes into account only the distances to the turtles that are part of the same component as the current turtle, since distance to turtles in other components is undefined. The closeness centrality of an isolated turtle is defined to be zero.
        ;


    if seeding-method = "degree" [ ; PA ****** (ref, get degrees - https://stackoverflow.com/questions/48005320/how-to-get-the-top-10-turtles-sorted-by-reverse-in-degree-centrality)
      if Seed-Order = "Descending" [
        let most-connected reverse sort-on [ count my-links ] max-n-of budget turtles [ count my-links ]
        let a-set-most-connected turtles with [member? self most-connected] ; not sure why above is a list and not an agentset, this converts it to an agentset
        ask a-set-most-connected [
          set adopted? true
          set seeded? true ;; -PA *****
;          show count my-links
          update-color
        ]
      ]
      if Seed-Order = "Ascending" [
        let least-connected sort-on [ count my-links ] min-n-of budget turtles [ count my-links ]
        let a-set-least-connected turtles with [member? self least-connected] ; not sure why above is a list and not an agentset, this converts it to an agentset
        ask a-set-least-connected [
          set adopted? true
          set seeded? true ;; -PA *****
;          show count my-links
          update-color
        ]
      ]
    ]
  ]

; ;For the actual networks (except padgettm and padgettmb), for time and computing purposes, I precooked the lists of most and least central nodes for the actual networks.
  ;NetLogo actually blew up trying to calculate closeness and betweeness on the below networks even after I increased memory to 30MB.
  ;NetworkX on Python takes about 8 hours to calculate centrality measures once for Francis-Bacon, Citations and Enron.
;--------------- Francis Bacon


; revising syntax
  if network-type = "francis-bacon" and seeding-method = "betweenness" [
    if Seed-Order = "Descending" [
      set seedlist ["10011671" "10011681" "10011670" "10012117" "10012119" "10011683" "10011673" "10013308" "10011687" "10007495" "10013301" "10000802" "10003058" "10005826" "10009549" "10012116" "10007175" "10013084" "10002251" "10011666" "10007966" "10002249" "10006720" "10006459" "10001806" "10012122" "10006462" "10001962" "10009592" "10011177" "10006686" "10011735" "10005550" "10012482" "10009828" "10011570" "10003060" "10000407" "10000142" "10005756"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10000001" "10000009" "10010729" "10008329" "10001508" "10000597" "10000014" "10000018" "10006909" "10009787" "10000024" "10006981" "10000027" "10000029" "10000030" "10000034" "10000035" "10006729" "10000039" "10000041" "10011541" "10000043" "10000046" "10000965" "10000053" "10000055" "10000057" "10002602" "10000058" "10004995" "10000551" "10005767" "10012360" "10000068" "10001924" "10000069" "10000080" "10009077" "10006820" "10009024"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

    if network-type = "francis-bacon" and seeding-method = "closeness" [
    if Seed-Order = "Descending" [
      set seedlist ["10011671" "10011670" "10011673" "10011681" "10007966" "10006686" "10005826" "10003497" "10005724" "10000231" "10012117" "10003058" "10007495" "10010928" "10007388" "10009549" "10007175" "10013301" "10006012" "10013300" "10011683" "10008729" "10011689" "10010919" "10009981" "10004101" "10006720" "10013308" "10012460" "10008712" "10001806" "10010872" "10001984" "10001036" "10000802" "10006753" "10009174" "10008364" "10000589" "10002069"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10000041" "10011541" "10000140" "10004255" "10000164" "10001131" "10000187" "10001382" "10000239" "10001793" "10000255" "10007313" "10000333" "10000335" "10000448" "10008473" "10000512" "10009087" "10000592" "10000595" "10000631" "10008055" "10000646" "10004816" "10000686" "10000688" "10000697" "10000699" "10000731" "10000732" "10000751" "10000754" "10000766" "10011168" "10000909" "10000918" "10000933" "10000934" "10000937" "10009496"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]



    if network-type = "francis-bacon" and seeding-method = "degree" [
    if Seed-Order = "Descending" [
      set seedlist ["10011671" "10011670" "10011681" "10012119" "10011683" "10012117" "10013308" "10012116" "10002251" "10007175" "10003058" "10012122" "10011666" "10012118" "10013084" "10002249" "10012482" "10006459" "10000802" "10002977" "10006462" "10003061" "10009549" "10001243" "10009828" "10005550" "10006720" "10011735" "10003747" "10003060" "10008475" "10004684" "10001806" "10009320" "10009799" "10012492" "10007966" "10012478" "10000596" "10010937"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10000009" "10010729" "10008329" "10000597" "10006909" "10009787" "10000024" "10000027" "10000029" "10000030" "10000034" "10000035" "10000039" "10000041" "10011541" "10000043" "10000046" "10000965" "10000053" "10000055" "10000058" "10012360" "10000069" "10000080" "10006820" "10009024" "10000095" "10000099" "10000101" "10008361" "10011256" "10004466" "10000115" "10000116" "10000119" "10000121" "10000125" "10000128" "10005145" "10010511"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show count my-links
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

; --------------- Francis-Bacon90 "Francis-Bacon90"


  if network-type = "francis-bacon90" and seeding-method = "betweenness" [
    if Seed-Order = "Descending" [
      set seedlist ["10012117" "10011673" "10011671" "10011681" "10011670" "10012119" "10013301" "10012122" "10011683" "10006459" "10013308" "10009351" "10008309" "10003058" "10002249" "10010937" "10009549" "10006012" "10009828" "10000596" "10050160" "10008522" "10000473" "10011735" "10008555" "10055016" "10007175" "10010612" "10007966" "10006697" "10008308" "10011091" "10002251" "10011666" "10011177" "10005652" "10011845" "10006720" "10055015" "10012827"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10012117" "10011673" "10011671" "10011681" "10011670" "10012119" "10013301" "10012122" "10011683" "10006459" "10013308" "10009351" "10008309" "10003058" "10002249" "10010937" "10009549" "10006012" "10009828" "10000596" "10050160" "10008522" "10000473" "10011735" "10008555" "10055016" "10007175" "10010612" "10007966" "10006697" "10008308" "10011091" "10002251" "10011666" "10011177" "10005652" "10011845" "10006720" "10055015" "10012827"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

    if network-type = "francis-bacon90" and seeding-method = "closeness" [
    if Seed-Order = "Descending" [
      set seedlist ["10011673" "10012117" "10011681" "10011671" "10011670" "10013271" "10002249" "10013301" "10010078" "10013300" "10003058" "10013279" "10050218" "10050160" "10007966" "10012122" "10000473" "10009981" "10002251" "10005652" "10013291" "10009351" "10011683" "10009549" "10011459" "10008364" "10000112" "10013308" "10006737" "10010937" "10008522" "10010612" "10006012" "10006686" "10011091" "10002357" "10011554" "10011845" "10006254" "10007175"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10000673" "10004086" "10005538" "10006568" "10001660" "10005594" "10001702" "10009767" "10001050" "10008069" "10011658" "10002153" "10003220" "10003221" "10000107" "10000443" "10000589" "10005379" "10005360" "10006167" "10004216" "10006402" "10051829" "10051540" "10005147" "10005149" "10008339" "10054708" "10012445" "10013101" "10006569" "10006570" "10050603" "10009795" "10050053" "10000188" "10050495" "10054739" "10008296" "10008298"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]



    if network-type = "francis-bacon90" and seeding-method = "degree" [
    if Seed-Order = "Descending" [
      set seedlist ["10012119" "10011671" "10011681" "10012117" "10011670" "10011683" "10013308" "10003058" "10009828" "10007175" "10002249" "10002251" "10012122" "10001243" "10011666" "10012116" "10005652" "10004684" "10006697" "10008475" "10012118" "10002977" "10008309" "10011735" "10010937" "10003743" "10005550" "10012482" "10006720" "10005740" "10003061" "10001806" "10009549" "10005491" "10000802" "10008812" "10006462" "10006459" "10007040" "10007171"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["10002455" "10013027" "10004348" "10000673" "10004086" "10001356" "10000330" "10005538" "10006568" "10012304" "10011499" "10006644" "10001660" "10005594" "10009392" "10001702" "10009767" "10001050" "10008069" "10011658" "10002153" "10006163" "10009178" "10004279" "10003220" "10003221" "10005758" "10004117" "10054693" "10009798" "10000107" "10000443" "10000589" "10005379" "10005360" "10006167" "10009127" "10012431" "10054704" "10004773"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

;--------------- enron  "enron-mail"


  ; revising syntax
  if network-type = "enron-mail" and seeding-method = "betweenness" [
    if Seed-Order = "Descending" [
      set seedlist ["5038" "140" "566" "588" "1139" "273" "458" "46" "1028" "292" "195" "370" "823" "136" "76" "286" "734" "543" "1768" "353" "647" "893" "416" "127" "95" "443" "613" "4746" "851" "213" "175" "1824" "155" "478" "530" "1559" "5030" "652" "887" "151"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["0" "2" "8" "10" "14" "17" "20" "22" "23" "24" "26" "28" "29" "33" "34" "36" "37" "38" "40" "43" "47" "48" "57" "61" "63" "64" "66" "67" "68" "10606" "961" "962" "189" "6826" "5031" "5034" "5039" "5047" "5054" "5055"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

    if network-type = "enron-mail" and seeding-method = "closeness" [
    if Seed-Order = "Descending" [
      set seedlist ["136" "76" "46" "140" "370" "292" "195" "734" "175" "416" "1139" "458" "444" "566" "353" "1028" "241" "188" "273" "588" "134" "478" "520" "78" "106" "265" "851" "423" "88" "639" "213" "27" "93" "481" "802" "74" "516" "5" "499" "3161"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["2086" "2087" "9505" "9506" "11684" "11685" "13352" "13353" "13354" "13355" "13358" "13359" "13575" "13576" "13593" "13594" "13595" "13596" "13625" "13626" "13641" "13642" "13643" "13644" "13729" "13730" "13907" "13908" "13910" "13911" "13958" "13959" "14848" "14849" "14855" "14856" "14857" "14858" "15160" "15161"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]



    if network-type = "enron-mail" and seeding-method = "degree" [
    if Seed-Order = "Descending" [
      set seedlist ["5038" "273" "458" "140" "1028" "195" "370" "1139" "136" "566" "823" "292" "588" "76" "416" "286" "353" "734" "851" "1824" "478" "95" "893" "516" "444" "520" "647" "652" "343" "543" "213" "443" "155" "175" "530" "127" "4063" "188" "639" "241"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["0" "2" "8" "14" "17" "20" "22" "23" "24" "26" "28" "29" "33" "34" "36" "37" "38" "40" "43" "47" "48" "57" "61" "63" "64" "66" "67" "68" "6826" "5054" "2095" "2102" "2104" "2108" "2113" "103" "130" "139" "152" "170"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]


; ---------------- citation  citations
 ; revising syntax
  if network-type = "citations" and seeding-method = "betweenness" [
    if Seed-Order = "Descending" [
      set seedlist ["73647" "52658" "101355" "22757" "101425" "46269" "78667" "46016" "56672" "15439" "8536" "26075" "97632" "101191" "91392" "107009" "15345" "9991" "52364" "15113" "83197" "97788" "84209" "96866" "35171" "31762" "106876" "38468" "33410" "66800" "22987" "45942" "28575" "12915" "1895" "46066" "95940" "52421" "42316" "101472"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["11894" "94" "46745" "67665" "5489" "38677" "89659" "44830" "46918" "61080" "7471" "14609" "17522" "23175" "31712" "48647" "67225" "90234" "7684" "95669" "22195" "29867" "73447" "8924" "50338" "87177" "90859" "96677" "102290" "107708" "44481" "55919" "4560" "11486" "14848" "22425" "37521" "37812" "49647" "50364"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]

    if network-type = "citations" and seeding-method = "closeness" [
    if Seed-Order = "Descending" [
      set seedlist ["73647" "52658" "46269" "15439" "46016" "101425" "101355" "97632" "45942" "22757" "12915" "53880" "22987" "46066" "52364" "43683" "15822" "78667" "52421" "56672" "101472" "96866" "15345" "107009" "83197" "88071" "52726" "42316" "62217" "68811" "42792" "87484" "83259" "52228" "15113" "95940" "97788" "8416" "45810" "18871"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["92829" "22494" "60328" "70103" "61714" "63184" "35388" "67324" "49343" "75438" "31928" "61999" "65138" "65146" "29764" "66052" "99139" "99928" "59443" "100000" "49035" "96001" "71995" "86180" "23343" "5838" "62040" "106369" "45137" "78181" "16876" "34620" "31818" "99765" "90734" "55372" "67558" "70983" "38645" "85192"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]



    if network-type = "citations" and seeding-method = "degree" [
    if Seed-Order = "Descending" [
      set seedlist ["73647" "52658" "78667" "97632" "22987" "101425" "97788" "15439" "46269" "45942" "46016" "95372" "83259" "22757" "91392" "101355" "12915" "905" "95940" "88071" "87484" "26130" "26750" "29380" "101191" "26075" "40271" "57070" "25735" "84209" "64428" "45810" "30874" "107009" "61271" "8536" "23411" "20247" "11063" "43683"]
    ]
    if Seed-Order = "Ascending" [
       set seedlist ["7471" "67225" "22195" "73447" "96677" "44481" "55919" "11486" "37521" "94997" "33964" "2367" "31664" "4904" "67147" "7105" "97238" "92829" "22494" "10237" "21743" "65125" "78995" "74641" "8466" "77730" "31362" "24048" "41934" "50807" "105537" "60328" "70103" "48275" "98474" "1645" "40978" "31769" "103819" "96821"]
      ]
        repeat budget
			    [let tnode first seedlist
;			    show tnode
        	ask turtles with [label = tnode] [
			    set adopted? true
			    set seeded? true
;			    show label
			    ]
			    set seedlist remove-item 0 seedlist
  			  ]]



  ; ---------------------

end

; ask turtles with [label = "10000001"] [set seeded? true set adopted? true] inspect turtle 0





;; create the social network
to create-network

  if network-type = "random" [ create-random-network ]
  if network-type = "preferential-attachment" [ create-preferential-attachment ]
  if network-type = "small-world" [ create-smallworld-network ] ;; PA
  if network-type = "francis-bacon" [ create-francisbacon-network ] ;; PA
  if network-type = "francis-bacon90" [ create-francisbacon-network90 ] ;; PA
  if network-type = "enron-mail" [ create-enron-network ] ;; PA
  if network-type = "citations" [ create-citation-network ] ;; PA
  if network-type = "padgettm" [ create-padgettm-network ] ;; PA
  if network-type = "padgettmb" [ create-padgettmb-network ] ;; PA
  if network-type = "nxrandom100" [ create-nxrandom100-network ] ;; PA
  if network-type = "nxrandom500" [ create-nxrandom500-network ] ;; PA
  if network-type = "nxrandom1000" [ create-nxrandom1000-network ] ;; PA
  if network-type = "nxrandom2000" [ create-nxrandom2000-network ] ;; PA
end

;; the Barabasi-Albert method of creating a PA graph
to create-preferential-attachment
  nw:generate-preferential-attachment turtles links num_agents 1 [
    set size 2
    set shape "circle"
    set color blue
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
  ]
end

;; generate an Erdos-Renyi random graph
to create-random-network
  nw:generate-random turtles links num_agents 0.004 [
    set shape "circle"
    set color blue
    set size 2
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
  ]
end


;; generate an Smaill World Network  - PA ADDED *******
to create-smallworld-network
nw:generate-watts-strogatz turtles links num_agents 2 0.1 [
    set shape "circle"
    set color blue
    set size 2
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
  ]
end

;; nw:generate-watts-strogatz turtle-breed link-breed num-nodes neighborhood-size rewire-probability optional-command-block


;; generate Francis Bacon Network  - PA ADDED *******
to create-francisbacon-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/sixdeg.gml" turtles links [
    set shape "circle"
    ;set label ""
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

to create-francisbacon-network90
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/sixdeg90.gml" turtles links [
    set shape "circle"
    ;set label ""
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end
;; generate Enron Mail Network  - PA ADDED *******
to create-enron-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/enron.gml" turtles links [
    set shape "circle"
    ;set label ""
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

;; generate Citation Network  - PA ADDED *******
to create-citation-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/citations.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

to create-padgettm-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/PadgettM.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

to create-padgettmb-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/PadgettMB.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end




; These random networks were created in NetworkX to verify that the NetLogo generate networks primitives were creating random
; networks appropriately.  It was found that NetLogo is doing so.  The Erdos/Reni algorithm used for random network creation
; by both NetLogo and NetworkX results in an increased "small-world" phenomenon as num-agents is increased, a linear change in
; num-agents results in an exponetial change of links and connectivity.  Due to time constraints, this phenomenon was explored
; more fully for this project.

; The bottom line is that NetLogo is creating random networks correctly!

to create-nxrandom100-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/nxrandom100.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

to create-nxrandom500-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/nxrandom500.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end


to create-nxrandom1000-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/nxrandom1000.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

to create-nxrandom2000-network
nw:load "/Users/paulalbert/OneDrive - George Mason University/CSS 635  Cognition/Python/nxrandom2000.gml" turtles links [
    set shape "circle"
    set node_id label ;;-PA *****
    ;set label "" ;;  -PA *****
    ;set who label ;; can't change who label
    set color blue
    set size 1
    set adopted? false
    set random? false ;; -PA *****
    set seeded? false ;; -PA *****
]
end

;; simple loop just check to see if a turtle hasn't adopted then decide if they should adopt



;;
;; utility procedures
;;
to update-color
  if adopted? [ set color yellow ] ;; -PA modified from red ****
end

to layout
  layout-spring turtles links 1 14 1.5
  display
end

to generate-network-metrics ;; - create base network metrics PA**** Not called anymore, metrics were reported as 0
  ;; global-clustering-coefficient
  let closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of turtles
  let triplets sum [ count my-links * (count my-links - 1) ] of turtles
  if triplets != 0 [set global-clustering-coefficient closed-triplets / triplets]
  if triplets = 0 [set global-clustering-coefficient  0]
  ;; seeded-clustering-coefficient
  set closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of turtles with [seeded?]
  set triplets sum [ count my-links * (count my-links - 1) ] of turtles with [seeded?]
  set seeded-clustering-coefficient closed-triplets / triplets
  ;; avg-seeded-clustering-coefficient
  set avg-seeded-clustering-coefficient mean [ nw:clustering-coefficient ] of turtles with [seeded?]

end

;to-report global-clustering-coefficient ;; - PA *** think this works
;  let closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of turtles
;  let triplets sum [ count my-links * (count my-links - 1) ] of turtles
;  if triplets != 0 [report closed-triplets / triplets]
;  if triplets = 0 [report 0]
;end


;to-report seeded-clustering-coefficient ;; - PA ***
;  let closed-triplets sum [ nw:clustering-coefficient * count my-links * (count my-links - 1) ] of turtles with [seeded?]
;  let triplets sum [ count my-links * (count my-links - 1) ] of turtles with [seeded?]
;  report closed-triplets / triplets
;end

;to-report avg-seeded-clustering-coefficient ;; - PA ***
;  let avgcc mean [ nw:clustering-coefficient ] of turtles with [seeded?]
;  report avgcc
;end


; Copyright 2012 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
263
19
925
682
-1
-1
6.48
1
10
1
1
1
0
1
1
1
-50
50
-50
50
1
1
1
ticks
30.0

BUTTON
85
364
155
397
layout
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
18
364
81
397
setup
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
20
398
155
431
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

CHOOSER
11
93
146
138
seeding-method
seeding-method
"betweenness" "random" "closeness" "degree"
3

CHOOSER
11
14
145
59
network-type
network-type
"random" "preferential-attachment" "small-world" "francis-bacon" "francis-bacon90" "enron-mail" "citations" "padgettm" "padgettmb" "nxrandom100" "nxrandom500" "nxrandom1000" "nxrandom2000"
1

SLIDER
11
58
145
91
budget
budget
1
11
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
314
182
347
num_agents
num_agents
100
10000
600.0
100
1
NIL
HORIZONTAL

SLIDER
13
193
232
226
Base_Likelihood_to_Imitate
Base_Likelihood_to_Imitate
0
1
0.4
.1
1
NIL
HORIZONTAL

SLIDER
13
230
244
263
Base_Likelihood_to_Innovate
Base_Likelihood_to_Innovate
0
.3
0.02
.01
1
NIL
HORIZONTAL

SLIDER
11
272
192
305
Threshold-Deviation
Threshold-Deviation
0
.8
0.0
.2
1
NIL
HORIZONTAL

CHOOSER
13
143
151
188
Seed-Order
Seed-Order
"Ascending" "Descending"
1

@#$#@#$#@
## ACKNOWLEDGMENT

This project extends the basic "Simple Viral Marketing" model that ships with NetLogo.

Model Extensions (Paul Albert, 5/6/21):

* Allows for examination of sample historical networks as well as generated networks
* Allows for examination of additional centrality seeding strategies (e.g., degree, closeness)
* Allows for examination of different generated network sizes (number of agents)
* Allows for examination of different seeding orders (most central vs. least central)
* Allows for examination of small-world networks as well as preferential attachment and random networks
* Allows for examination of different values for Innovation and Imitation Coefficients
* Allows for examination of introducing heterogenity in innovation and imitation coefficients

The base model is from Chapter Eight of the book "Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo", by Uri Wilensky & William Rand.

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

The base model is in the IABM Textbook folder of the NetLogo Models Library. The model, as well as any updates to the model, can also be found on the textbook website: http://www.intro-to-abm.com/.

## WHAT IS IT?

This model is a simple experiment that allows researchers to examine how to best seed a network to maximize the adoption rate of a product by using viral marketing.

Its purpose is to allow you to explore the relationship between different centrality measures, and different network types, and see if the interactions between them make for faster or slower spread of the product.

## HOW IT WORKS

When the model is set up, a selected number turtles are created and connected in a network of the type selected (preferential attachment or a random network). A number of turtles are seeded with the product at time 0. At each tick, each turtle has a small chance of adopting the product on their own (Innovation Coefficient), and a larger chance of adopting the product if any of their friends have adopted the product (Imitation Coefficient).

The model stops when the whole market is saturated.

## HOW TO USE IT

Start by selecting a type of network. Then choose how many turtles are initially seeded and by what centrality measure these turtles are selected.

When you click SETUP, the network will be generated, and when you click GO, nodes will start infecting their neighbors.

## THINGS TO TRY

Try to set up different kinds of networks, and select the initially seeded turtles by different centrality measures. Are there particular measures that might result in a faster spread in particular types of networks, but not in others? Why do you think that is?

## EXTENDING THE MODEL

The model was inspired by the Local Viral Marketing Problem (Stonedahl, Rand & Wilensky 2010) of an adoption network. Currently the model simply measures how fast a virus spreads on a network, but does not take into account how fast it is spread to each individual node which is one way to calculate the net present value (NPV) of a strategy. If the model were to fully implement the NPV of a model, the value of each infected node would depend on at what time it was infected.

Further, the model currently allows for only two different network types and four centrality measures. These could be extended as well.

Finally, the model only allows users to choose one centrality measure by which to initially infect turtles. Ideally it would be possible to set a number of infected turtles, and choose proportions of centrality measures to infect these turtles.

## CREDITS AND REFERENCES

Stonedahl, Forrest, William Rand, and Uri Wilensky (2010), "Evolving Viral Marketing Strategies," Genetic and Evolutionary Computation Conference (GECCO), July 7-11, Portland, OR, USA

Rand, William M. and Rust, Roland T., Agent-Based Modeling in Marketing: Guidelines for Rigor (June 10, 2011). International Journal of Research in Marketing, 2011; Robert H. Smith School Research Paper No. RHS 06-132. Available at SSRN: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1818543

This model is a simplified model based on another model by Arthur Hjorth (arthur.hjorth@u.northwestern.edu).

## HOW TO CITE

The base model is part of the textbook, “Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo.”

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the base model itself:

* Rand, W. & Wilensky, U. (2012).  NetLogo Simple Viral Marketing model.  http://ccl.northwestern.edu/netlogo/models/SimpleViralMarketing.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the textbook as:

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

## COPYRIGHT AND LICENSE FOR BASE MODEL

Copyright 2012 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2012 Cite: Rand, W. & Wilensky, U. -->
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
NetLogo 6.1.1
@#$#@#$#@
setup repeat 40 [ layout ] repeat 15 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="SNA Experiment Base" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <enumeratedValueSet variable="centrality-measure">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="1" last="10"/>
  </experiment>
  <experiment name="4_3_22 Working Sweep" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="1" last="10"/>
  </experiment>
  <experiment name="4_3_22 Working Sweep _ add random" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>global-clustering-coefficient</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="num_agents">
      <value value="500"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_5_22 Working Sweep playing w reporters" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>global-clustering-coefficient</metric>
    <metric>seeded-clustering-coefficient</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="1" last="10"/>
    <enumeratedValueSet variable="num_agents">
      <value value="500"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_14_22 PA Simple Viral 1 rep make simpler" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="11"/>
    <enumeratedValueSet variable="num_agents">
      <value value="500"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
  </experiment>
  <experiment name="4_15_22 PA SVM Gen Networks 10 Rep" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="9"/>
    <enumeratedValueSet variable="num_agents">
      <value value="500"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
  </experiment>
  <experiment name="4_14_22 PA v3 SVM Actual Networks" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="11"/>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
  </experiment>
  <experiment name="4_14_22 PA v3 SVM Actual Networks Fin Run" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="9"/>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="Random-Choice-In-List">
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_15_22 PA v3 SVM Actual Networks Fin Run" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="9"/>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="Random-Choice-In-List">
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_15_22 PA SVM Gen Networks 15 Rep" repetitions="15" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>;note here</metric>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="2" last="9"/>
    <enumeratedValueSet variable="num_agents">
      <value value="500"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Heterogeneous_Likelihoods">
      <value value="&quot;No&quot;"/>
      <value value="&quot;Yes&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.03"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
  </experiment>
  <experiment name="4_16_20 SVM Generated Networks" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Base_Likelihood_to_Imitate">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
      <value value="500"/>
      <value value="1000"/>
      <value value="10000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Descending&quot;"/>
      <value value="&quot;Ascending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_21_20  Generated Networks" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.005"/>
      <value value="0.01"/>
      <value value="0.015"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;small-world&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="100"/>
      <value value="500"/>
      <value value="1000"/>
      <value value="10000"/>
      <value value="200000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Descending&quot;"/>
      <value value="&quot;Ascending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_22_21 Actual Networks Fin Run" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.1" last="0.2"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
      <value value="&quot;francis-bacon90&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_25_21 Actual Networks Fin Run (wo Padgett) fix innovate likelihood" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.02"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
      <value value="&quot;francis-bacon90&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_26_21 Padgett Networks Fin Run fixed innovate" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <steppedValueSet variable="Base_Likelihood_to_Innovate" first="0" step="0.01" last="0.02"/>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;padgettm&quot;"/>
      <value value="&quot;padgettmb&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="budget" first="1" step="1" last="10"/>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="4_26_21 Networkx Random Network Sweep" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.005"/>
      <value value="0.01"/>
      <value value="0.015"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Base_Likelihood_to_Imitate" first="0.3" step="0.1" last="0.6"/>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;nxrandom100&quot;"/>
      <value value="&quot;nxrandom500&quot;"/>
      <value value="&quot;nxrandom1000&quot;"/>
      <value value="&quot;nxrandom2000&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Threshold-Deviation" first="0" step="0.2" last="0.6"/>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Descending&quot;"/>
      <value value="&quot;Ascending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5_2_21 Gen Networks Run" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>1 - ((num_agents - count turtles with [ adopted? ]) / num_agents)</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.01"/>
      <value value="0.02"/>
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Base_Likelihood_to_Imitate">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;small-world&quot;"/>
      <value value="&quot;preferential-attachment&quot;"/>
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-Deviation">
      <value value="0"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_agents">
      <value value="16"/>
      <value value="100"/>
      <value value="500"/>
      <value value="1000"/>
      <value value="2000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5_2_21 Actual Networks Run" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>count turtles with [ adopted? = false ]</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.01"/>
      <value value="0.02"/>
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Base_Likelihood_to_Imitate">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;citations&quot;"/>
      <value value="&quot;enron-mail&quot;"/>
      <value value="&quot;francis-bacon&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-Deviation">
      <value value="0"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="5_2_21 Padgett Networks Fin Run fixed innovate" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <exitCondition>all? turtles [ adopted? ]</exitCondition>
    <metric>count turtles with [ adopted? ]</metric>
    <metric>count turtles with [ random? ]</metric>
    <metric>count turtles with [ adopted? = false ]</metric>
    <enumeratedValueSet variable="Base_Likelihood_to_Innovate">
      <value value="0.01"/>
      <value value="0.02"/>
      <value value="0.03"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Base_Likelihood_to_Imitate">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seeding-method">
      <value value="&quot;betweenness&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;closeness&quot;"/>
      <value value="&quot;degree&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;padgettm&quot;"/>
      <value value="&quot;padgettmb&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="budget">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Threshold-Deviation">
      <value value="0"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Seed-Order">
      <value value="&quot;Ascending&quot;"/>
      <value value="&quot;Descending&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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

#set text(font: "Times New Roman", size: 13pt)
#set heading(numbering: "1.")
#set page("a4")
#import "@preview/codly:1.2.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()
#codly(languages: codly-languages, zebra-fill: none, stroke: black + 1pt)
#show raw: set text(font: "JetBrains Mono", size: 10pt) 

#set table(
  fill: (x, y) =>
    if y == 0 { luma(240) }
    else if x == 0{ luma(250) },
)

#show table.cell.where(y: 0): strong

#set table(align: left + horizon)

#let version = raw(read("version.txt"))
#let uit-color = rgb("#4a63b8")

#page(margin: 1cm)[
  #rect(width: 100%, height: 100%, stroke: 3pt + uit-color)[
    #pad(rest: 10pt)[
      #align(center)[
        #text(size: 17pt)[*ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH*] \
        #text[*TRƯỜNG ĐẠI HỌC CÔNG NGHỆ THÔNG TIN*] \
        #text[*KHOA CÔNG NGHỆ PHẦN MỀM*] \ 
        #text(fill: white, size: 20pt)[SECRET: version #version]
        #v(50pt)
        #image("images/logo-uit.svg", width: 200pt)
      ]
      #align(horizon + center)[
        #text(size: 23pt)[*Phát triển ứng dụng trên nền tảng dữ liệu lớn*] \
        #v(3pt)
        #text(size: 28pt)[*Fake News Detection*] \
        #v(20pt)

        #text[Giảng viên hướng dẫn] \
        #text[*TS. Đỗ Trọng Hợp*] \
        #text[*Nguyễn Ngọc Quí*] \

        #v(10pt)

        #text[Sinh viên thực hiện] \
        #text[*Hồ Nguyễn Tài Lợi #sym.dash.en 23520869*] \
        #text[*Nguyễn Trung Kiên #sym.dash.en 23520802*] \
      ]
      #align(bottom + center)[
        #text(size: 13pt)[
          #text[Thành phố Hồ Chí Minh], ngày
          #datetime.today().display("[day]/[month]/[year]")
        ]
      ]
    ]
  ]

]



#pagebreak()
#show outline.entry.where(level: 1): it => {
  set text(size: 14pt, weight: "bold")
  set block(above: 1em)
  [#text(size: 14pt)[
    #link(it.element.location())[Chương #it.prefix() #it.inner()]]
  ]
}


#include "thank.typ"
#pagebreak()

#outline(
  title: [
    #text([Mục lục], size: 30pt)
    #v(10pt)
  ],
  depth: 4
)
#pagebreak()

#set page(numbering: "1")

#show heading.where(level: 1): it => {
  [Chương #counter(heading).at(here()).at(0). ] + it.body
}

#include "abstract.typ"
#pagebreak()

#include "introduction.typ"
#pagebreak()

#include "related-work.typ"
#pagebreak()

#include "problem-statement.typ"
#pagebreak()

#include "system-architecture.typ"
#pagebreak()

#include "de-lm.typ"
#pagebreak()

#include "human-feedback.typ"
#pagebreak()

#include "continuous-learning.typ"
#pagebreak()

#include "evaluation.typ"
#pagebreak()

#include "limitations-risks.typ"
#pagebreak()

#include "future-work.typ"
#pagebreak()

#include "conclusion.typ"
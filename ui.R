## (c) Keisuke Kondo
## Date (First Version): 2022-10-28
## Date (Latest Version): 2022-10-28
## 
## - global.R
## - server.R
## - ui.R
## 

#HEADER-------------------------------------------------------------------------
header <- dashboardHeader(
  title = "移住シミュレーション",
  titleWidth = 300,
  disable = FALSE
)
#SIDEBAR------------------------------------------------------------------------
sidebar <- dashboardSidebar(
  width = 300,
  #++++++++++++++++++++++++++++++++++++++
  #CSS
  useShinyjs(),
  tags$head(
    # Include CSS
    includeCSS("styles.css")
  ),
  #++++++++++++++++++++++++++++++++++++++
  h2(span(style="border-bottom: solid 1px white;", "シミュレーション設定")),
  #NOTE
  p("移住の費用便益を計算します。"),
  div(
    id="slider_inline",
    # Annual Nominal Income before Migration
    sliderInput(
      "preincome",
      "移住前の年間所得（万円）",
      min = 100,
      max = 1500,
      value = 300,
      step = 10
    ),
    # Annual Nominal Income after Migration
    sliderInput(
      "postincome",
      "移住後の年間所得（万円）",
      min = 100,
      max = 1500,
      value = 300,
      step = 10
    ),
    # Migration Costs
    sliderInput(
      "subsidy",
      "移住支援金（万円）",
      min = 0,
      max = 1000,
      value = 60,
      step = 10
    ),
    # Relative Costs of Livings
    sliderInput(
      "costofliving",
      "相対生計費（移住後の生計費が低いと１より小さい値を取る）",
      min = 0.1,
      max = 3,
      value = 0.8,
      step = 0.01
    ),
    # Migration Distance from Tokyo
    sliderInput(
      "distance",
      "移住距離（km）",
      min = 0,
      max = 1000,
      value = 500,
      step = 10
    ),
    # Distance Decay Parameter
    sliderInput(
      "delta",
      "距離減衰パラメータ（詳細は「モデル」を参照）",
      min = 0,
      max = 0.5,
      value = 0.186,
      step = 0.001
    ),
  ),
  # Migration Distance from Tokyo
  div(
    actionButton("buttonSimulation", span(icon("play-circle"), "シミュレーション"), class="btn btn-info"),
    p("「シミュレーション」を押してください。")
  )
)
#BODY---------------------------------------------------------------------------
body <- dashboardBody(
  #++++++++++++++++++++++++++++++++++++++
  #CSS
  useShinyjs(),
  tags$head(
    # Include CSS
    includeCSS("styles.css")
  ),
  #++++++++++++++++++++++++++++++++++++++
  ####################################
  ## NAVBARPAGE
  ## - Visualize simulation
  ## - Model
  ## - Author
  ## - Terms of Use
  ## - Github
  ####################################
  navbarPage(
    span(style="font-weight:bold;color:white", "MENU"),
    id = "navbarpageMain",
    theme = shinytheme("yeti"),
    #++++++++++++++++++++++++++++++++++++++
    ####################################
    ## TABPANEL
    ## - Visualization
    ## - Model
    ## - Author
    ## - Terms of Use
    ## - Github
    ####################################
    tabPanel(
      "移住シミュレーション", 
      icon = icon("chart-bar"),
      div(
        style = "margin-left: -25px; margin-right: -25px;",
        #------------------------------------------------
        fluidRow(
          column(
            width = 12,
            div(
              style = "margin: 10px",
              h2(span(icon("chart-line"), "移住シミュレーション")),
              p("移住シミュレーションの結果は以下の通りです。"),
            ),
            div(
              style = "margin: 15px -5px -5px -5px;",
              column(
                width = 12,
                offset = 0,
                style="padding: 0px;",
                valueBoxOutput("vBox1", width = 4),
                valueBoxOutput("vBox2", width = 4),
                valueBoxOutput("vBox3", width = 4)
              ),
              column(
                width = 12,
                offset = 0,
                style="padding: 0px;",
                valueBoxOutput("vBox4", width = 6),
                valueBoxOutput("vBox5", width = 6)
              )
            )
          ),
          column(
            width = 12,
            div(
              style = "margin: 0px 10px 10px 10px;",
              box(
                width = NULL,
                solidHeader = FALSE,
                linePlotUI("linePlot")
                )
              )
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "モデル", 
      icon = icon("file-alt"),
      div(
        style="margin-left: -30px; margin-right: -30px;",
        #
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("file-alt"), "モデル")), 
            solidHeader = TRUE,
            #
            withMathJax(),
            #
            p("公開日：2022年10月28日", align="right"),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "はじめに"),
            p("本研究（近藤, 2019）では、地方創生における移住支援金政策を事前評価するための簡易的な分析枠組みを提案しています。移住支援金の金額をどのように決めたらいいのか、現在の金額でどれほどの政策効果があるのかについて、政策を実施する前から具体的な数値に基づいて議論できるように研究を行っています。"
            ),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "移住の離散選択モデル"),
            p("地域\\(i\\)に住む個人が、地域\\(j\\)に\\(T\\)年だけ居住するという意思決定を行う状況を考えます。どの地域に住むと最も高い効用が得られるのかという効用最大化の観点から、様々な仮定に基づき数理モデルを記述します。移住先の地域\\(j\\)には、地域\\(i\\)も含まれます。地域\\(j = i\\)を選択した場合は現在の居住地に住み続けることを意味します。"),
            p("本研究では、地方移住を投資行動として捉え、移住時に発生する一括の移住費用を、移住後に毎期発生する便益によって何期間かけて返済していくのかという構造を定式化しています。移住後に毎期発生する便益の累積和が移住費用を超える時点が投資回収に必要な居住期間となります。それ以降の居住から移住の純便益が正になることを意味します。つまり、各個人が実際に住もうと考えている期間が、この投資回収に必要な居住期間より長ければ移住を決定し、短ければ移住しないという意思決定を行うと考えます。移住支援金は，この投資回収に必要な居住期間を短くすることで，地方移住へのインセンティブを高めることにつながると解釈しています。"),
            p("移住便益\\( \\mathrm{MB} \\)と移住費用\\( \\mathrm{MB} \\)は、本モデルよりそれぞれ以下のように計算されます。"),
            p("移住便益（単位：実質所得）：\\( \\mathrm{MB} = T ( \\omega_{j} - \\omega_{i} ) + \\dfrac{S_{j}}{P_{j}} \\)"),
            p("移住費用（単位：実質所得）：\\( \\mathrm{MC} = ( D_{ij}^{\\delta} - D_{ii}^{\\delta} ) \\omega_{i} \\)"),
            p("ここで、\\( \\omega_{j} \\)は地域\\(j\\)の実質所得、\\( \\omega_{i} \\)は地域\\(i\\)の実質所得、\\( S_{j} \\)は地域\\(j\\)への移住で得られる移住支援金（名目所得）、\\( P_{j} \\)は地域\\(j\\)の生計費、\\( D_{ij} \\)は地域\\(i\\)と地域\\(j\\)の間の移住距離、\\( \\delta \\)は距離減衰パラメータになります。実質賃金\\( \\omega \\)は、名目所得\\( I \\)と生計費\\( P \\)を用いて、\\( \\omega = I/P\\)として表されます。地域\\(i\\)から地域\\(j\\)への移住費用は、移住距離と距離減衰パラメータを用いて、\\(  D_{ij}^{\\delta} \\)と表します。地域\\(i\\)に居住し続ける場合の移住費用は、\\(  D_{ii}^{\\delta} = 1 \\)となります。"),
            p("本研究のシミュレーションでは、居住先と移住先の名目所得と生計費は各自で設定する変数として考えます。生計費については、移住先\\(j\\)と居住先\\(i\\)の相対生計費\\( P_{j} / P_{i} \\)として設定します。移住費用は距離減衰パラメータ\\( \\delta \\)に依存しますが、実際に人々がどのような数値を持っているのかわかりません。そこで、実際の移住フローのデータから推定することで移住費用を推計します。"),
            p("移住による投資回収に必要な居住期間\\(\\bar{T}\\)は、\\( \\mathrm{MB} = \\mathrm{MC} \\)の条件より、\\(T\\)について求めます。その他詳細は近藤(2019)を参照してください。"),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "距離減衰パラメータの推定値"),
            p("シミュレーション設定における「距離減衰パラメータ」を決める際、自分の属性に近い数値を参考にしてください。"),
            h4(style="text-decoration: underline;", "全国の市区町村間の移住フローより推定"),
            p("全国の市町村間で移住した人々のデータより、距離減衰パラメータを推定しています。"),
            column(
              width = 12,
              tableOutput("tableDeltaAllMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaAllFemale")
            ),
            h4(style="text-decoration: underline;", "東京23区への移住フローより推定"),
            p("東京23区へ移住した人々のデータより、距離減衰パラメータを推定しています。"),
            column(
              width = 12,
              tableOutput("tableDeltaInMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaInFemale")
            ),
            h4(style="text-decoration: underline;", "東京23区からの移住フローより推定"),
            p("東京23区から移住した人々のデータより、距離減衰パラメータを推定しています。"),
            column(
              width = 12,
              tableOutput("tableDeltaOutMale")
            ),
            column(
              width = 12,
              tableOutput("tableDeltaOutFemale")
            ),
            #------------------------------------------------------------------
            h3(style="border-bottom: solid 1px black;", "参考文献"),
            HTML("<p>近藤恵介(2019) 「東京一極集中と地方への移住促進」、 RIETI PDP No. 19-P-006（2022年11月改訂）</p>"),
            p("URL: ", a(href = "https://www.rieti.go.jp/jp/publications/summary/19040007.html", "https://www.rieti.go.jp/en/publications/summary/19040007.html", .noWS = "outside"), .noWS = c("after-begin", "before-end"))
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "作成者", 
      icon = icon("user"),
      div(
        style="margin-left: -30px;margin-right: -30px;",
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("user"), "作成者")), 
            solidHeader = TRUE,
            h3(style="border-bottom: solid 1px black;", "作成者"),
            p("近藤恵介"),
            p("独立行政法人経済産業研究所・上席研究員"),
            p("神戸大学経済経営研究所・准教授"),
            h3(style="border-bottom: solid 1px black;", "連絡先"),
            p("Email: kondo-keisuke@rieti.go.jp"),
            p("URL: ", a(href = "https://keisukekondokk.github.io/", "https://keisukekondokk.github.io/", .noWS = "outside"), .noWS = c("after-begin", "before-end")),
            p("住所:東京都千代田区霞が関1-3-1　経済産業省別館11階"),
            a(href="https://www.rieti.go.jp/en/", img(src="logo_rieti.jpeg", width= "480" )),
            br(clear="right"),
            br(),
            p("ここに述べられている見解は執筆者個人の責任で発表するものであり、所属する組織および独立行政法人経済産業研究所としての見解を示すものではありません。")
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "利用規約", 
      icon = icon("file-signature"),
      div(
        style="margin-left: -30px;margin-right: -30px;",
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("file-signature"), "利用規約")), 
            solidHeader = TRUE,
            p("当サイトで公開している情報（以下「コンテンツ」）は、どなたでも自由に利用できます。コンテンツ利用に当たっては、本利用規約に同意したものとみなします。本利用規約の内容は、必要に応じて事前の予告なしに変更されることがありますので、必ず最新の利用規約の内容をご確認ください。"),
            h3("著作権"),
            p("本コンテンツの著作権は、近藤恵介に帰属します。"),
            h3("第三者の権利"),
            HTML("<p>コンテンツの一部に第三者の著作物が含まれる場合があります。利用者は第三者の著作権を侵害しないように事前に確認してください。</p>"),
            h3("ライセンス "),
            p("MITライセンスのもとで公開されています。"),
            h3("免責事項"),
            HTML("<ul>
            <li>(a) 作成にあたり細心の注意を払っていますが、本サイトの内容の完全性・正確性・有用性等についていかなる保証を行うものでありません。</li>
            <li>(b) 本サイトを利用したことによるすべての障害・損害・不具合等、作成者および作成者の所属するいかなる団体・組織とも、一切の責任を負いません。</li>
            <li>(c) 本サイトは、事前の予告なく変更、移転、削除等が行われることがあります。</li>
            </ul>"),
            br(),
            br(),
            p("公開日：2022年10月28日"),
            br()
          )
        )
      )
    ),
    #++++++++++++++++++++++++++++++++++++++
    tabPanel(
      "GitHub", 
      icon = icon("github"),
      div(
        style="margin-left: -30px;margin-right: -30px;",
        column(
          width = 12,
          box(
            width = NULL, 
            title = h2(span(icon("github"), "GitHub")), 
            solidHeader = TRUE,
            h3("コード公開"),
            p("Shiny appのRコードはGithubより入手可能です。"),
            p("URL: ", a(href = "https://keisukekondokk.github.io/", "https://keisukekondokk.github.io/", .noWS = "outside"), .noWS = c("after-begin", "before-end")),
            p("URL: ", a(href = "https://github.com/keisukekondokk/migration-simulator-jp", "https://github.com/keisukekondokk/migration-simulator-jp", .noWS = "outside"), .noWS = c("after-begin", "before-end"))
          )
        )
      )
    )
  )
)
#DASHBOARD----------------------------------------------------------------------
dashboardPage(
  header,
  sidebar,
  body
)

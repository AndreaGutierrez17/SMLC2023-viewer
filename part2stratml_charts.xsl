<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="no"/>

  <!-- Helpers -->
  <xsl:template name="text-or-attr">
    <xsl:param name="ctx"/>
    <xsl:choose>
      <xsl:when test="$ctx/*[local-name()='Value']">
        <xsl:value-of select="normalize-space($ctx/*[local-name()='Value'])"/>
      </xsl:when>
      <xsl:when test="$ctx/@Value">
        <xsl:value-of select="normalize-space($ctx/@Value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($ctx)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="num">
    <xsl:param name="s"/>
    <xsl:variable name="clean" select="translate(normalize-space($s), '%$,₱€£¥ ', '')"/>
    <xsl:value-of select="number($clean)"/>
  </xsl:template>

  <xsl:template name="date-of">
    <xsl:param name="ctx"/>
    <xsl:choose>
      <xsl:when test="$ctx/*[local-name()='Date']">
        <xsl:value-of select="normalize-space($ctx/*[local-name()='Date'])"/>
      </xsl:when>
      <xsl:when test="$ctx/@Date">
        <xsl:value-of select="normalize-space($ctx/@Date)"/>
      </xsl:when>
      <xsl:when test="$ctx/*[local-name()='Period']">
        <xsl:value-of select="normalize-space($ctx/*[local-name()='Period'])"/>
      </xsl:when>
      <xsl:otherwise>—</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="unit-of">
    <xsl:param name="ctx"/>
    <xsl:choose>
      <xsl:when test="$ctx/*[local-name()='Unit']">
        <xsl:value-of select="normalize-space($ctx/*[local-name()='Unit'])"/>
      </xsl:when>
      <xsl:when test="$ctx/@Unit">
        <xsl:value-of select="normalize-space($ctx/@Unit)"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- Root -->
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>
          <xsl:choose>
            <xsl:when test="//*[local-name()='Name']">
              <xsl:value-of select="normalize-space(//*[local-name()='Name'][1])"/>
            </xsl:when>
            <xsl:otherwise>StratML Viewer (Charts)</xsl:otherwise>
          </xsl:choose>
        </title>
        <link rel="stylesheet" href="styles.css"/>
        <!-- El JS no es necesario; los navegadores bloquean JS en XSLT. -->
      </head>
      <body>
        <header>
          <div class="wrap">
            <div class="byline">
              <xsl:variable name="logo" select="(//*[local-name()='LogoURI' or local-name()='LogoURL' or local-name()='Logo']/text())[1]"/>
              <xsl:if test="string-length(normalize-space($logo)) &gt; 0">
                <img class="logo" alt="Logo" src="{normalize-space($logo)}" onerror="this.style.display='none'"/>
              </xsl:if>
              <div>
                <div class="title">
                  <xsl:value-of select="normalize-space(//*[local-name()='Name'][1])"/>
                </div>
                <div class="subtitle">
                  <xsl:value-of select="normalize-space(//*[local-name()='Description'][1])"/>
                </div>
              </div>
            </div>
          </div>
        </header>

        <main class="wrap">
          <div class="grid">
            <aside class="toc">
              <h3>Contents</h3>
              <details open="open"><summary>Overview</summary>
                <div class="muted">
                  <div><span class="pill">Mission</span> <xsl:value-of select="normalize-space(//*[local-name()='Mission'][1])"/></div>
                  <div><span class="pill">Vision</span> <xsl:value-of select="normalize-space(//*[local-name()='Vision'][1])"/></div>
                </div>
              </details>
              <details open="open">
                <summary>Values</summary>
                <ol>
                  <xsl:for-each select="//*[local-name()='Value']">
                    <li><xsl:value-of select="normalize-space(.)"/></li>
                  </xsl:for-each>
                </ol>
              </details>
              <details>
                <summary>Objectives</summary>
                <ol>
                  <xsl:for-each select="//*[local-name()='Objective']">
                    <li><a href="#obj-{position()}"><xsl:value-of select="normalize-space(./*[local-name()='Name'][1] | ./@Name | .)"/></a></li>
                  </xsl:for-each>
                </ol>
              </details>
            </aside>

            <section>
              <xsl:for-each select="//*[local-name()='Objective']">
                <div class="card" id="obj-{position()}">
                  <h2 style="margin:0 0 4px">
                    <xsl:value-of select="normalize-space(./*[local-name()='Name'][1] | ./@Name | .)"/>
                  </h2>
                  <div class="muted"><xsl:value-of select="normalize-space(./*[local-name()='Description'][1])"/></div>
                  <xsl:for-each select=".//*[local-name()='PerformanceIndicator']">
                    <xsl:call-template name="render-indicator"/>
                  </xsl:for-each>
                </div>
              </xsl:for-each>

              <xsl:if test="count(//*[local-name()='Objective'])=0">
                <xsl:for-each select="//*[local-name()='PerformanceIndicator']">
                  <xsl:call-template name="render-indicator"/>
                </xsl:for-each>
              </xsl:if>
            </section>
          </div>
        </main>

        <footer class="wrap" style="margin-top:30px;color:#666">
          <small>StratML (ISO 17469-1). XSL con tablas y gráficos SVG (sin JS). Indicadores: Target vs Actual; Bar/Line/Table/Progress.</small>
        </footer>
      </body>
    </html>
  </xsl:template>

  <!-- Indicator card -->
  <xsl:template name="render-indicator">
    <div class="card pi-card">
      <h4>
        <xsl:value-of select="normalize-space(./*[local-name()='Name'][1] | ./@Name | .)"/>
      </h4>
      <div class="muted">
        <xsl:value-of select="normalize-space(./*[local-name()='Description'][1])"/>
      </div>

      <xsl:variable name="targets" select="./*[local-name()='TargetResult']"/>

      <!-- Arrays para tabla (aún útiles) -->
      <xsl:variable name="labels">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$targets">
          <xsl:variable name="d">
            <xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template>
          </xsl:variable>
          <xsl:if test="position()&gt;1">,</xsl:if>
          "<xsl:value-of select="translate($d,'&quot;','')"/>"
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="targetsArr">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$targets">
          <xsl:variable name="t"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="."/></xsl:call-template></xsl:variable>
          <xsl:if test="position()&gt;1">,</xsl:if>
          <xsl:call-template name="num"><xsl:with-param name="s" select="$t"/></xsl:call-template>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="actualsArr">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="$targets">
          <xsl:variable name="dateT">
            <xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template>
          </xsl:variable>
          <xsl:variable name="matchA"
            select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($dateT) or normalize-space(@Date)=normalize-space($dateT)][1]"/>
          <xsl:variable name="aval">
            <xsl:choose>
              <xsl:when test="$matchA">
                <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$matchA"/></xsl:call-template>
              </xsl:when>
              <xsl:otherwise>NaN</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="position()&gt;1">,</xsl:if>
          <xsl:choose>
            <xsl:when test="string($aval)='NaN'">null</xsl:when>
            <xsl:otherwise><xsl:call-template name="num"><xsl:with-param name="s" select="$aval"/></xsl:call-template></xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
      </xsl:variable>

      <xsl:variable name="unit">
        <xsl:call-template name="unit-of"><xsl:with-param name="ctx" select="($targets|./*[local-name()='ActualResult'])[1]"/></xsl:call-template>
      </xsl:variable>

      <div class="toolbar" aria-label="Indicator view">
        <button class="active">Table</button>
        <button>Bar</button>
        <button>Line</button>
        <button>Progress</button>
        <span class="pill"><xsl:value-of select="$unit"/></span>
      </div>

      <!-- TABLE -->
      <div class="view view-table">
        <table aria-label="Target vs Actual table">
          <thead><tr><th>Period</th><th>Target</th><th>Actual</th><th>Status</th></tr></thead>
          <tbody>
            <xsl:for-each select="$targets">
              <xsl:variable name="d"><xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template></xsl:variable>
              <xsl:variable name="t"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="."/></xsl:call-template></xsl:variable>
              <xsl:variable name="aNode"
                select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($d) or normalize-space(@Date)=normalize-space($d)][1]"/>
              <xsl:variable name="a"><xsl:choose>
                <xsl:when test="$aNode"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$aNode"/></xsl:call-template></xsl:when>
                <xsl:otherwise>—</xsl:otherwise>
              </xsl:choose></xsl:variable>
              <xsl:variable name="tn"><xsl:call-template name="num"><xsl:with-param name="s" select="$t"/></xsl:call-template></xsl:variable>
              <xsl:variable name="an"><xsl:call-template name="num"><xsl:with-param name="s" select="$a"/></xsl:call-template></xsl:variable>
              <tr>
                <td><xsl:value-of select="$d"/></td>
                <td><xsl:value-of select="$t"/></td>
                <td><xsl:value-of select="$a"/></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="number($an) &gt;= number($tn) and not($a='—')">
                      <span class="status-ok">✔ Met</span>
                    </xsl:when>
                    <xsl:when test="$a='—'">
                      <span class="muted">No data</span>
                    </xsl:when>
                    <xsl:otherwise>
                      <span class="status-bad">✖ Under</span>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </div>

      <!-- BAR (SVG, sin JS) -->
      <div class="view view-bar">
        <div class="chart-wrap">
          <svg xmlns="http://www.w3.org/2000/svg" width="960" height="320" role="img" aria-label="Bar chart: Target vs Actual">
            <xsl:variable name="h" select="220"/>
            <xsl:variable name="top" select="20"/>
            <xsl:variable name="left" select="60"/>
            <xsl:variable name="barW" select="18"/>
            <xsl:variable name="gap" select="14"/>
            <xsl:variable name="group" select="$barW*2 + $gap"/>
            <xsl:variable name="acts" select="./*[local-name()='ActualResult']"/>

            <!-- máximos -->
            <xsl:variable name="maxT">
              <xsl:for-each select="./*[local-name()='TargetResult']">
                <xsl:sort data-type="number"
                  select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                <xsl:if test="position()=last()">
                  <xsl:value-of select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="maxA">
              <xsl:for-each select="$acts">
                <xsl:sort data-type="number"
                  select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                <xsl:if test="position()=last()">
                  <xsl:value-of select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="max">
              <xsl:choose>
                <xsl:when test="number($maxT) &gt;= number($maxA)"><xsl:value-of select="number($maxT)"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="number($maxA)"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <!-- ejes y grid -->
            <line x1="{$left}" y1="{$top+$h}" x2="{$left+800}" y2="{$top+$h}" stroke="#ddd"/>
            <line x1="{$left}" y1="{$top}" x2="{$left}" y2="{$top+$h}" stroke="#ddd"/>
            <xsl:for-each select="'0.25','0.50','0.75','1.00'">
              <xsl:variable name="p" select="number(.)"/>
              <line x1="{$left}" x2="{$left+800}"
                    y1="{$top + $h - round($h * $p)}"
                    y2="{$top + $h - round($h * $p)}"
                    stroke="#eee"/>
            </xsl:for-each>

            <!-- barras -->
            <xsl:for-each select="./*[local-name()='TargetResult']">
              <xsl:variable name="i" select="position()"/>
              <xsl:variable name="d">
                <xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template>
              </xsl:variable>
              <xsl:variable name="t">
                <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="."/></xsl:call-template>
              </xsl:variable>
              <xsl:variable name="tn">
                <xsl:call-template name="num"><xsl:with-param name="s" select="$t"/></xsl:call-template>
              </xsl:variable>
              <xsl:variable name="aNode"
                select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($d) or normalize-space(@Date)=normalize-space($d)][1]"/>
              <xsl:variable name="a">
                <xsl:choose>
                  <xsl:when test="$aNode">
                    <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$aNode"/></xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="an">
                <xsl:call-template name="num"><xsl:with-param name="s" select="$a"/></xsl:call-template>
              </xsl:variable>

              <xsl:variable name="gx" select="$left + $group * ($i - 1)"/>
              <xsl:variable name="tH" select="round($h * number($tn) div number($max))"/>
              <xsl:variable name="aH" select="round($h * number($an) div number($max))"/>

              <!-- Target -->
              <rect x="{$gx}" width="{$barW}"
                    y="{$top + $h - $tH}" height="{$tH}"
                    fill="#d7e6ff" stroke="#0b57d0"/>
              <!-- Actual -->
              <rect x="{$gx + $barW}" width="{$barW}"
                    y="{$top + $h - $aH}" height="{$aH}"
                    fill="#cdeed6" stroke="#148f2d"/>

              <!-- etiqueta período -->
              <text x="{$gx + $barW}" y="{$top + $h + 14}" text-anchor="middle" font-size="11">
                <xsl:value-of select="$d"/>
              </text>
            </xsl:for-each>

            <!-- leyenda -->
            <rect x="{$left+4}" y="{$top-14}" width="10" height="10" fill="#d7e6ff" stroke="#0b57d0"/>
            <text x="{$left+20}" y="{$top-5}" font-size="11">Target</text>
            <rect x="{$left+70}" y="{$top-14}" width="10" height="10" fill="#cdeed6" stroke="#148f2d"/>
            <text x="{$left+86}" y="{$top-5}" font-size="11">Actual</text>
          </svg>
        </div>
      </div>

      <!-- LINE (SVG, sin JS) -->
      <div class="view view-line">
        <div class="chart-wrap">
          <svg xmlns="http://www.w3.org/2000/svg" width="960" height="320" role="img" aria-label="Line chart: Target vs Actual">
            <xsl:variable name="h" select="220"/>
            <xsl:variable name="top" select="20"/>
            <xsl:variable name="left" select="60"/>
            <xsl:variable name="group" select="50"/>

            <!-- máximo global -->
            <xsl:variable name="maxAll">
              <xsl:for-each select="./[local-name()='TargetResult'] | ./[local-name()='ActualResult']">
                <xsl:sort data-type="number"
                  select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                <xsl:if test="position()=last()">
                  <xsl:value-of select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <!-- ejes -->
            <line x1="{$left}" y1="{$top+$h}" x2="{$left+800}" y2="{$top+$h}" stroke="#ddd"/>
            <line x1="{$left}" y1="{$top}" x2="{$left}" y2="{$top+$h}" stroke="#ddd"/>

            <!-- puntos TARGET -->
            <xsl:variable name="ptsT">
              <xsl:for-each select="./*[local-name()='TargetResult']">
                <xsl:variable name="i" select="position()"/>
                <xsl:variable name="t"
                  select="number(translate(normalize-space((./*[local-name()='Value']|@Value|.)[1]), '%$,₱€£¥ ', ''))"/>
                <xsl:variable name="x" select="$left + $group * $i"/>
                <xsl:variable name="y" select="$top + $h - round($h * $t div number($maxAll))"/>
                <xsl:if test="position() &gt; 1"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select="concat($x,',',$y)"/>
              </xsl:for-each>
            </xsl:variable>
            <polyline points="{$ptsT}" fill="none" stroke="#0b57d0" stroke-width="2" stroke-dasharray="4 4"/>

            <!-- puntos ACTUAL -->
            <xsl:variable name="ptsA">
              <xsl:for-each select="./*[local-name()='TargetResult']">
                <xsl:variable name="i" select="position()"/>
                <xsl:variable name="d">
                  <xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template>
                </xsl:variable>
                <xsl:variable name="aNode"
                  select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($d) or normalize-space(@Date)=normalize-space($d)][1]"/>
                <xsl:variable name="a" select="number(translate(normalize-space(( $aNode/*[local-name()='Value'] | $aNode/@Value | $aNode )[1]), '%$,₱€£¥ ', ''))"/>
                <xsl:variable name="x" select="$left + $group * $i"/>
                <xsl:variable name="y" select="$top + $h - round($h * $a div number($maxAll))"/>
                <xsl:if test="position() &gt; 1"><xsl:text> </xsl:text></xsl:if>
                <xsl:value-of select="concat($x,',',$y)"/>
              </xsl:for-each>
            </xsl:variable>
            <polyline points="{$ptsA}" fill="none" stroke="#148f2d" stroke-width="2"/>
          </svg>
        </div>
      </div>

      <!-- PROGRESS -->
      <div class="view view-progress">
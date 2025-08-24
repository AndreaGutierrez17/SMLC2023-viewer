<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="no"/>


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
        <script src="charts.js"></script>
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
          <small>StratML (ISO 17469-1). XSL with charts (no external deps). Indicators: Target vs Actual; Bar/Line/Table/Progress; green ≥ target, red &lt; target.</small>
        </footer>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="render-indicator">
    <xsl:variable name="this" select="."/>
    <div class="card pi-card">
      <h4>
        <xsl:value-of select="normalize-space(./*[local-name()='Name'][1] | ./@Name | .)"/>
      </h4>
      <div class="muted">
        <xsl:value-of select="normalize-space(./*[local-name()='Description'][1])"/>
      </div>

      <xsl:variable name="targets" select="./*[local-name()='TargetResult']"/>

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
            select="../*[local-name()='ActualResult'][normalize-space(./*[local-name()='Date'])=normalize-space($dateT) or normalize-space(@Date)=normalize-space($dateT)][1]"/>
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

      <div class="toolbar" role="tablist" aria-label="Indicator view">
        <button class="active" data-view="table" role="tab">Table</button>
        <button data-view="bar" role="tab">Bar</button>
        <button data-view="line" role="tab">Line</button>
        <button data-view="progress" role="tab">Progress</button>
        <span class="pill"><xsl:value-of select="$unit"/></span>
      </div>

      <div class="view view-table">
        <table aria-label="Target vs Actual table">
          <thead><tr><th>Period</th><th>Target</th><th>Actual</th><th>Status</th></tr></thead>
          <tbody>
            <xsl:for-each select="$targets">
              <xsl:variable name="d"><xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template></xsl:variable>
              <xsl:variable name="t"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="."/></xsl:call-template></xsl:variable>
              <xsl:variable name="aNode"
                select="../*[local-name()='ActualResult'][normalize-space(./*[local-name()='Date'])=normalize-space($d) or normalize-space(@Date)=normalize-space($d)][1]"/>
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

      <div class="view view-bar" style="display:none">
        <div class="chart-wrap">
          <canvas class="pi-chart" role="img" aria-label="Bar chart: Target vs Actual"
                  width="900" height="300"
                  data-labels="{$labels}"
                  data-targets="{$targetsArr}"
                  data-actuals="{$actualsArr}"
                  data-kind="bar"></canvas>
        </div>
      </div>

      <div class="view view-line" style="display:none">
        <div class="chart-wrap">
          <canvas class="pi-chart" role="img" aria-label="Line chart: Target vs Actual"
                  width="900" height="300"
                  data-labels="{$labels}"
                  data-targets="{$targetsArr}"
                  data-actuals="{$actualsArr}"
                  data-kind="line"></canvas>
        </div>
      </div>

      <div class="view view-progress" style="display:none">
        <xsl:variable name="tLast">
          <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$targets[last()]"/></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="aLast">
          <xsl:variable name="dLast"><xsl:call-template name="date-of"><xsl:with-param name="ctx" select="$targets[last()]"/></xsl:call-template></xsl:variable>
          <xsl:variable name="aNodeLast" select="../*[local-name()='ActualResult'][normalize-space(./*[local-name()='Date'])=normalize-space($dLast) or normalize-space(@Date)=normalize-space($dLast)][1]"/>
          <xsl:choose>
            <xsl:when test="$aNodeLast"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$aNodeLast"/></xsl:call-template></xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tn"><xsl:call-template name="num"><xsl:with-param name="s" select="$tLast"/></xsl:call-template></xsl:variable>
        <xsl:variable name="an"><xsl:call-template name="num"><xsl:with-param name="s" select="$aLast"/></xsl:call-template></xsl:variable>
        <xsl:variable name="pct">
          <xsl:choose>
            <xsl:when test="number($tn)&gt;0">
              <xsl:value-of select="round(100*number($an) div number($tn))"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <div class="muted" style="margin-bottom:6px">
          Progress (last period): <strong><xsl:value-of select="$aLast"/></strong> of <strong><xsl:value-of select="$tLast"/></strong> (<xsl:value-of select="$pct"/>%)
        </div>
        <div class="progress" aria-label="Progress bar">
          <span style="width:{concat($pct, '%')};"></span>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>

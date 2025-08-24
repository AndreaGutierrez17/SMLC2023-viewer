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

  <!-- Layout -->
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
            <xsl:otherwise>StratML Viewer</xsl:otherwise>
          </xsl:choose>
        </title>
        <!-- Tu CSS externo (déjalo igual) -->
        <link rel="stylesheet" href="styles.css"/>
        <!-- Importante: sin charts.js (los navegadores no ejecutan JS en XSLT) -->
        <style>
          html,body{margin:0;padding:0;background:#fff;color:#111;font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;line-height:1.45}
          a{color:#0b57d0;text-decoration:none} a:hover{text-decoration:underline}
          header{position:sticky;top:0;background:#fff;border-bottom:1px solid #e6e6e6;z-index:5}
          .wrap{max-width:1200px;margin:0 auto;padding:20px}
          .title{font-size:28px;font-weight:800;margin:8px 0 2px}
          .subtitle{color:#444;margin:0 0 10px}
          .grid{display:grid;grid-template-columns:300px 1fr;gap:24px}
          @media (max-width:1000px){.grid{grid-template-columns:1fr}}
          .toc{border:1px solid #e6e6e6;border-radius:12px;padding:14px;background:#fafafa}
          .toc h3{margin:0 0 8px;font-size:16px}
          details{border:1px solid #eaeaea;border-radius:10px;padding:8px 10px;background:#fff;margin-bottom:8px}
          summary{cursor:pointer;font-weight:600}
          .card{border:1px solid #e6e6e6;border-radius:14px;padding:16px;background:#fff;box-shadow:0 1px 2px rgba(0,0,0,.04);margin-bottom:16px}
          .pi-card h4{margin:0 0 6px;font-size:18px}
          .muted{color:#555}
          table{border-collapse:collapse;width:100%}
          th,td{border-bottom:1px solid #eee;padding:8px;text-align:left;vertical-align:middle}
          .pill{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #e6e6e6;background:#f4f6fb;color:#0b57d0;font-size:12px}
          .status-ok{color:#148f2d;font-weight:700}
          .status-bad{color:#c62828;font-weight:700}
          .spark{width:100%;height:16px;display:block}
          .spark .bg{fill:#f0f2f5}
          .spark .tbar{fill:#9aa4b2}
          .spark .abar.ok{fill:#17a34a}
          .spark .abar.bad{fill:#e11d48}
        </style>
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
          <small>StratML (ISO 17469-1). XSL with SVG charts (no JS). Target vs Actual por período; verde = cumple, rojo = debajo.</small>
        </footer>
      </body>
    </html>
  </xsl:template>

  <!-- Indicador con SVG sin JS -->
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
      <xsl:variable name="unit">
        <xsl:call-template name="unit-of">
          <xsl:with-param name="ctx" select="($targets|./*[local-name()='ActualResult'])[1]"/>
        </xsl:call-template>
      </xsl:variable>

      <div class="toolbar" style="margin:10px 0">
        <span class="pill"><xsl:value-of select="$unit"/></span>
      </div>

      <div class="view view-table">
        <table aria-label="Target vs Actual">
          <thead>
            <tr>
              <th>Period</th>
              <th>Target</th>
              <th>Actual</th>
              <th>Status</th>
              <th style="width:260px">Graph</th>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="$targets">
              <xsl:variable name="d">
                <xsl:call-template name="date-of"><xsl:with-param name="ctx" select="."/></xsl:call-template>
              </xsl:variable>
              <xsl:variable name="t">
                <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="."/></xsl:call-template>
              </xsl:variable>
              <xsl:variable name="aNode"
                select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($d) or normalize-space(@Date)=normalize-space($d)][1]"/>
              <xsl:variable name="a">
                <xsl:choose>
                  <xsl:when test="$aNode">
                    <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$aNode"/></xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>—</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="tn"><xsl:call-template name="num"><xsl:with-param name="s" select="$t"/></xsl:call-template></xsl:variable>
              <xsl:variable name="an"><xsl:call-template name="num"><xsl:with-param name="s" select="$a"/></xsl:call-template></xsl:variable>

              <!-- Porcentaje (an / tn) para la barrita -->
              <xsl:variable name="pct">
                <xsl:choose>
                  <xsl:when test="number($tn) &gt; 0 and not($a='—')">
                    <xsl:value-of select="round(100*number($an) div number($tn))"/>
                  </xsl:when>
                  <xsl:otherwise>-1</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

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
                <td>
                  <!-- Spark bar sin JS: barra gris (target=100), barra color (actual= pct%) -->
                  <svg class="spark" viewBox="0 0 100 16" preserveAspectRatio="none" role="img"
                       aria-label="Progress">
                    <rect class="bg" x="0" y="3" width="100" height="10" rx="5" ry="5"/>
                    <rect class="tbar" x="0" y="3" width="100" height="10" rx="5" ry="5" opacity="0.25"/>
                    <xsl:if test="number($pct) &gt;= 0">
                      <rect x="0" y="3" height="10" rx="5" ry="5">
                        <xsl:attribute name="width"><xsl:value-of select="$pct"/></xsl:attribute>
                        <xsl:attribute name="class">
                          <xsl:choose>
                            <xsl:when test="number($an) &gt;= number($tn)">abar ok</xsl:when>
                            <xsl:otherwise>abar bad</xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                      </rect>
                    </xsl:if>
                  </svg>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </div>

      <!-- Resumen progreso (último período) -->
      <xsl:variable name="tLast">
        <xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$targets[last()]"/></xsl:call-template>
      </xsl:variable>
      <xsl:variable name="aLast">
        <xsl:variable name="dLast"><xsl:call-template name="date-of"><xsl:with-param name="ctx" select="$targets[last()]"/></xsl:call-template></xsl:variable>
        <xsl:variable name="aNodeLast" select="../[local-name()='ActualResult'][normalize-space(./[local-name()='Date'])=normalize-space($dLast) or normalize-space(@Date)=normalize-space($dLast)][1]"/>
        <xsl:choose>
          <xsl:when test="$aNodeLast"><xsl:call-template name="text-or-attr"><xsl:with-param name="ctx" select="$aNodeLast"/></xsl:call-template></xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="tn"><xsl:call-template name="num"><xsl:with-param name="s" select="$tLast"/></xsl:call-template></xsl:variable>
      <xsl:variable name="an"><xsl:call-template name="num"><xsl:with-param name="s" select="$aLast"/></xsl:call-template></xsl:variable>
      <xsl:variable name="pctLast">
        <xsl:choose>
          <xsl:when test="number($tn)&gt;0">
            <xsl:value-of select="round(100*number($an) div number($tn))"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <div class="muted" style="margin-top:8px">
        Progress (last period): <strong><xsl:value-of select="$aLast"/></strong> of <strong><xsl:value-of select="$tLast"/></strong> (<xsl:value-of select="$pctLast"/>%)
      </div>

      <div class="progress" aria-label="Progress bar" style="height:14px;background:#f0f2f5;border-radius:12px;overflow:hidden;margin-top:6px">
        <span style="display:block;height:100%">
          <xsl:attribute name="style">
            <xsl:text>display:block;height:100%;</xsl:text>
            <xsl:text>background:</xsl:text>
            <xsl:choose>
              <xsl:when test="number($an) &gt;= number($tn)">#17a34a</xsl:when>
              <xsl:otherwise>#e11d48</xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:text>width:</xsl:text><xsl:value-of select="$pctLast"/><xsl:text>%;</xsl:text>
          </xsl:attribute>
        </span>
      </div>

    </div>
  </xsl:template>

</xsl:stylesheet>
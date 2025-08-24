
// ---- Minimal charting (Canvas 2D) for StratML indicators ----
(function(){
  function px(dpr, v){ return Math.round(v*dpr); }
  function parseArr(s){ try{ return JSON.parse(s||"[]"); }catch(e){ return []; } }
  function drawAxes(ctx,W,H,maxY,labels){
    ctx.save(); ctx.lineWidth=1; ctx.strokeStyle="#ddd"; ctx.fillStyle="#333"; ctx.font="12px system-ui, Arial";
    for(let i=0;i<=4;i++){
      const y = 40 + (H-60) * i/4;
      ctx.beginPath(); ctx.moveTo(50,y); ctx.lineTo(W-10,y); ctx.stroke();
      const v = maxY*(1-i/4);
      ctx.fillText(String(Math.round(v*100)/100), 5, y+4);
    }
    const n = labels.length; if(n>0){
      const innerW = W-70; const x0=50;
      for(let i=0;i<n;i++){
        const x = x0 + innerW*(i/(n-1||1));
        const lbl = (labels[i]||"").toString().slice(0,12);
        ctx.save(); ctx.translate(x,H-10); ctx.rotate(-Math.PI/6);
        ctx.fillText(lbl,0,0); ctx.restore();
      }
    }
    ctx.restore();
  }
  function maxAll(a,b){ return Math.max(1, Math.max.apply(null,a.concat(b).map(function(v){return +v||0;}))); }
  function bar(ctx,W,H,labels,actuals,targets){
    const maxY=maxAll(actuals,targets);
    drawAxes(ctx,W,H,maxY,labels);
    const n=labels.length, innerW=W-70, x0=50, barW=innerW/(n||1), barGroup=barW*0.8, gap=barW*0.2;
    for(let i=0;i<n;i++){
      const tx=x0 + i*barW + gap/2;
      const tg=(+targets[i]||0), ac=(+actuals[i]||0);
      const hT=(H-60)*(tg/maxY), hA=(H-60)*(ac/maxY);
      // target (soft blue)
      ctx.fillStyle="#b3c6ff"; ctx.fillRect(tx, H-20-hT, barGroup/2-3, hT);
      // actual (green/red)
      ctx.fillStyle= (ac>=tg) ? "#148f2d" : "#c62828";
      ctx.fillRect(tx+(barGroup/2)+3, H-20-hA, barGroup/2-3, hA);
    }
  }
  function line(ctx,W,H,labels,actuals,targets){
    const maxY=maxAll(actuals,targets);
    drawAxes(ctx,W,H,maxY,labels);
    const n=labels.length, innerW=W-70, x0=50, yBase=H-20;
    function pathFor(arr, color){
      ctx.beginPath(); ctx.lineWidth=2; ctx.strokeStyle=color;
      for(let i=0;i<n;i++){
        const x = x0 + innerW*(i/(n-1||1));
        const y = yBase - (H-60)*((+arr[i]||0)/maxY);
        if(i===0) ctx.moveTo(x,y); else ctx.lineTo(x,y);
      }
      ctx.stroke();
    }
    pathFor(targets,"#2b50a3");
    pathFor(actuals,"#148f2d");
  }
  function draw(canvas){
    const ctx = canvas.getContext("2d");
    const dpr = window.devicePixelRatio || 1;
    const cssW = canvas.getAttribute("width") ? +canvas.getAttribute("width") : canvas.clientWidth;
    const cssH = canvas.getAttribute("height") ? +canvas.getAttribute("height") : canvas.clientHeight;
    canvas.width = px(dpr, cssW); canvas.height = px(dpr, cssH); ctx.scale(dpr,dpr);
    const labels = parseArr(canvas.getAttribute("data-labels"));
    const actuals = parseArr(canvas.getAttribute("data-actuals"));
    const targets = parseArr(canvas.getAttribute("data-targets"));
    const kind = (canvas.getAttribute("data-kind")||"bar");
    ctx.clearRect(0,0,cssW,cssH);
    if(labels.length<=1){
      ctx.fillStyle="#666"; ctx.font="14px system-ui, Arial"; 
      ctx.fillText("Use 'Progress' view for a single Target/Actual pair.", 10, 20);
      return;
    }
    if(kind==="line") line(ctx, cssW, cssH, labels, actuals, targets);
    else bar(ctx, cssW, cssH, labels, actuals, targets);
  }
  function init(){
    document.querySelectorAll("canvas.pi-chart").forEach(draw);
    document.querySelectorAll(".toolbar button").forEach(function(btn){
      btn.addEventListener("click", function(){
        const wrap = btn.closest(".pi-card");
        wrap.querySelectorAll(".toolbar button").forEach(b=>b.classList.remove("active"));
        btn.classList.add("active");
        const view = btn.getAttribute("data-view");
        wrap.querySelectorAll(".view").forEach(v=>v.style.display="none");
        const el = wrap.querySelector(".view-"+view);
        if(el){
          el.style.display="";
          if(view==="bar" || view==="line"){
            const cnv = wrap.querySelector("canvas.pi-chart");
            cnv.setAttribute("data-kind", view==="bar"?"bar":"line");
            draw(cnv);
          }
        }
      });
    });
  }
  if(document.readyState!=="loading") init();
  else document.addEventListener("DOMContentLoaded", init);
})();

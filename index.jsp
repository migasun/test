<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ include file='lib.megic/v2012/func.jsp' %>
<%@ include file='lib.megic/v2012/dbcore.jsp' %>
<%!
DataPlus getItouchMenu( String dn )throws Exception{
	String SQL = "SELECT * FROM ST.CLASS_PROC WHERE URL NOT LIKE '%http%'";
	DataFactory df = new DataFactory(SQL);
		df.setDN(dn);
//long START = System.currentTimeMillis();
//System.out.println("計時開始：START = " + START);
	DataPlus dp = new DataPlus(df.getData());
//long DONE = System.currentTimeMillis();
//System.out.println("計時結束：DONE = " + DONE + " 耗時：DIFF = " + (DONE-START) + " ms.");
	return dp;
}

DataPlus menuDP = null;		//快取iTouch選單，初次執行撈DB可能要10秒。故快取之。
%>

<% 
String IP_FROM = getIpAddr(request);
boolean IP_DEV = "0:0:0:0:0:0:0:1".equals(IP_FROM)||matchReg("^140\\.135\\.5\\.\\d{1,3}$", IP_FROM)||matchReg("^127\\.0\\.0\\.\\d{1,3}$", IP_FROM);

if( !IP_DEV ){
	session.invalidate();
	out.println("抱歉，認證錯誤或已過期或非限定IP來源");
	response.setStatus(401);
	return ;
}

//用FORCE參數強制撈取DB
String force = request.getParameter("force");
if(force!=null){
	menuDP=null;
}

if(menuDP==null){
	TreeMap tm = new TreeMap();	//排序兼濾除重複
	
	DataPlus dp = getItouchMenu("st");
	for(int i=0,j=dp.size(); i<j;i++){
		tm.put(dp.getString(i, "url"), dp.get(i));
	}
	
	dp = getItouchMenu("absolut_db1_st");
	for(int i=0,j=dp.size(); i<j;i++){
		tm.put(dp.getString(i, "url"), dp.get(i));
	}	
	
	ArrayList trimedList = new ArrayList();
	
	HashMap ah = new HashMap();
		ah.put("cname", "iTouch登入後首頁");
		ah.put("url", "/home");
		ah.put("id", "r1");
		ah.put("memo", "root");
		ah.put("value", "/home");
		ah.put("label", "iTouch登入後首頁 /home root");
	trimedList.add(ah);
	
	ah = new HashMap();
		ah.put("cname", "學生1網通");
		ah.put("url", "/i3/s_web/open.jsp");
		ah.put("id", "r2");
		ah.put("memo", "root");
		ah.put("value", "/i3/s_web/open.jsp");
		ah.put("label", "學生1網通 /i3/s_web/open.jsp root");
	trimedList.add(ah);

	ah = new HashMap();
		ah.put("cname", "教師1網通");
		ah.put("url", "/i3/t_web/open.jsp");
		ah.put("id", "r3");
		ah.put("memo", "root");
		ah.put("value", "/i3/t_web/open.jsp");
		ah.put("label", "教師1網通 /i3/t_web/open.jsp root");
	trimedList.add(ah);		
	
	for(Object key : tm.keySet()) {//for 回圈
		HashMap tmk = (HashMap)tm.get(key);
		HashMap m = new HashMap();
			m.put("cname", tmk.get("cname"));
			m.put("url", tmk.get("url"));
			m.put("id", tmk.get("id"));
			m.put("memo", tmk.get("memo"));
			m.put("value", tmk.get("url"));
			m.put("label", (String)tmk.get("cname")+ " " +(String)tmk.get("url"));	
		trimedList.add(	m );
	}
	menuDP = new DataPlus(trimedList);
}

if(force!=null){
	response.sendRedirect("./");	//to reload page
}
out.clear();
%>
<!doctype html>
<html>
<head>
<meta charset="utf-8" >
<meta content="IE=edge" http-equiv="X-UA-Compatible">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<link rel="shortcut icon" href="./lib.megic/test.ico">
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/redmond/jquery-ui.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.2/animate.min.css">

<link rel="stylesheet" href="lib.megic/bootstrap.min.css">

<style>

tbody.class tr td{cursor:pointer;}
td.q1, td.memo{text-align:right}

@media (max-width:767px){
	#myForm div input[name="i"]{
		width:100%;
	};
}
@media (min-width:768px){
	#myForm div.col-sm-3{
		text-align:right;
	}
}
.black{
    display: inline-block;
    vertical-align: middle;
    float: none;
	margin-top:5px;
	margin-bottom:5px;
}

input[type='text'],input[type='number']{padding:5px 2px;}
input[type='text']:focus,input[type='number']:focus{background:#FF9;}

body *{font-family:"微軟正黑體", "標楷體", "新細明體";}
  .ui-autocomplete {
    max-height: 400px;
    overflow-y: auto;
    /* prevent horizontal scrollbar */
    overflow-x: hidden;
  }
</style>
<script src="https://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
<!--script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script-->
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=" crossorigin="anonymous"></script>
<script src="lib.megic/js/qrcode.min.js"></script>
<title>Magic 任意門</title>
<script>

$.ajaxSetup({
	error:function(x, status, error){
		var msg = '很抱歉...\n\n'+
				'目前發生讀取錯誤，我們將儘快維修，造成不便敬請見諒。\n為爭取時效，敬請主動與我們聯繫：電算中心客服專線1999。\n'+
				'本系統為「Magic任意門」\n\n'+
				'系統回應異常(代碼：'+x.status+')\n';
		if (x.status == 0) {}
		else if( x.status == 400 ){ // 無效/錯誤的參數			
			alert( '您提交的參數無效，請重新整理再試試看' );
		}else if( x.status == 401 ){ // 登入逾期/未登入
			alert( '很抱歉，權限不足或已過期，請重新登入');
		}else if( x.status == 403 ){ // 無效的權限
			alert( '很抱歉，權限不足或已過期，請重新登入' );
		}else{
			alert( msg + error );
		}
     }	
});

var clone_i = 1;

$(document).ready(function(e) {
	$('#accept').click(function(){
		var vaild = true;
		var msg = '';
		var i = $('input[name="i"]').val();
		var t = $('input[name="t"]').val();
		var u = $('input[name="u"]').val();
		var d = $('input[name="d"]').val();
		var pars = $('#myForm').serialize();
		var succ = function(result){
			$('#dataHolder').html($(result).find('#generatedJumper').html()).removeClass('w3-hide');
		};
		if( i == '' || u  == '' || d == '' ){
			vaild = false;
			msg = '請輸入條件\n\n星號欄位※ 代表必填。';
		}
		if( ! vaild ){
			$('input[name="i"]').focus();
			alert(msg);
		}else{
			$.post('jumper.jsp', pars, succ, 'html');
		}
	});
});

function clone(){
	clone_i ++;
	var clone = '<div class="row help-block clone">'+
				'<div class="col-sm-3 black">模擬對象人事代碼/學號'+clone_i+'</div><!--'+
				'--><div class="col-sm-9 black"><input class="" autocomplete="off" type="text" name="t" style="width:89%" />'+
					'<button type="button" name="remove" class="w3-btn w3-ripple w3-round w3-margin-left">Ｘ</button>'+
				'</div>'+
										'</div>' ;
	$('#clone').append(clone);
	$('#clone').children('div').children('div.col-sm-8').children('input').focus();
	$('#clone').removeClass('collapse');
};

//(function($, undefined) {	//自動調整autocomplete寬度
//'use strict';
//$.widget('ui.autocomplete', $.ui.autocomplete, {
//  _resizeMenu: function() {
//    var ul, lis, ulW, barW;
//    if (isNaN(this.options.maxShowItems)) { return; }
//    ul = this.menu.element
//      .scrollLeft(0).scrollTop(0) // Reset scroll position
//      .css({overflowX: '', overflowY: '', width: '', maxHeight: ''}); // Restore
//    lis = ul.children('li').css('whiteSpace', 'nowrap');
//
//    if (lis.length > this.options.maxShowItems) {
//      ulW = ul.prop('clientWidth');
//      ul.css({overflowX: 'hidden', overflowY: 'auto',
//        maxHeight: lis.eq(0).outerHeight() * this.options.maxShowItems + 1}); // 1px for Firefox
//      barW = ulW - ul.prop('clientWidth');
//      ul.width('+=' + barW);
//    }
//
//    // Original code from jquery.ui.autocomplete.js _resizeMenu()
//    ul.outerWidth(Math.max(
//      ul.outerWidth() + 1,
//      this.element.outerWidth()
//    ));
//  }
//});
//})(jQuery);

function UserListUi(){	
	/* 測試對象 */
	$(this).autocomplete({
		//maxShowItems:10,
		source: function( request, response ){
			$.ajax({
				url: 'megic.aj.information.jsp',
				dataType: 'json',
				data: { t : request.term },
				success: function( data ) {
					var result = new Array();
					$.each(data,function( index,value ){
						if( index >= 0 ){
							var lbl = value.idcode +' '+ value.uname +', ' +value.bln_admin + ' ' + value.dept_abvi_c + '('+value.title_name+')';
							if(value.ext){
								lbl+=' #'+value.ext;
							}
							result.push({
								label : lbl,
								value : value.idcode,
								name  : value.cname
							});
						} // end if 
					});
					response( result );
				}
			});
		},		
		minLength: 2,
		select: function (event, ui) {
			$(this).val(ui.item.value);
			/* 列出姓名 */
			return false;
		},
		open: function() {
			$( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
		},
		close: function() {
			$( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
		}		
	});
};

function pointreturnurl(){
	$('input[name="u"]').val($(this).find('td.url').html());
}

function filter(){
	var value = $(this).val();
	var msg = '';
	$('#urlmenu table tbody.class tr').each(function(){
		$(this).removeClass('w3-hide');
	});
	$('#urlmenu table tbody.class tr').each(function(){
		var isclose = true;
		$(this).children('td').each(function(){
			if( $(this).html().toLowerCase().indexOf(value.toLowerCase()) != -1 ){
				isclose = false;
			}
		})
		if(isclose){
			$(this).addClass('w3-hide');
		}
	});
};

function removeclone(){
	$(this).closest('div.row').remove();
}

$(document).on('keyup','input.filter',filter);
$(document).on('keyup','input[name="t"],input[name="i"]',UserListUi);
$(document).on('mouseup','#urlmenu table tr',pointreturnurl);
$(document).on('click','button[name="bt3"]',clone);
$(document).on('click','button[name="remove"]',removeclone);		

  $( function(){
	var fk = {};
	fk.showQR=function(evt){
		evt.preventDefault();
		$('#qrTitle').html($(this).html());
		fk.makeQrcode($(this).attr('href'));
		$('#diagQR').dialog( 'open' );
	}
	$(document).on('click', 'a.qrcode', fk.showQR);
	
	var qrcode = new QRCode(document.getElementById("qrcodeHere"),'');
	fk.makeQrcode=function(arg){
		qrcode.clear();
		qrcode.makeCode(arg);
	};

    $('#diagQR').dialog({
      resizable: false, title:'產生的QRCODE',
      height: "auto", width: 400,
      modal: true, autoOpen: false,
      buttons: {
        '關閉': function() {
          $( this ).dialog( 'close' );
        }
      }
    });//dialog
	
  });

function animateCSS(element, animationName, callback){
    const node = document.querySelector(element);
    node.classList.add('animated', animationName);

    function handleAnimationEnd() {
        node.classList.remove('animated', animationName);
        node.removeEventListener('animationend', handleAnimationEnd);

        if (typeof callback === 'function') callback();
    }

    node.addEventListener('animationend', handleAnimationEnd);
};

var fx = {};
fx.doCopyClicked = function(){
  var toCopy = document.querySelector('p.toCopy');
  var range = document.createRange();  
  range.selectNode(toCopy);  
  window.getSelection().addRange(range);  

  try {  
    // Now that we've selected the anchor text, execute the copy command  
    var successful = document.execCommand('copy');  
    var msg = successful ? 'successful' : 'unsuccessful';  

		$('#doCopy').addClass('w3-tooltip');
		$('#hint').removeClass('w3-hide');

	animateCSS('#doCopy','rubberBand', function(){
		var mute = function(){$('#hint').addClass('w3-hide');}
		setTimeout(mute, 5000);
	});

  } catch(err) {
	  alert('抱歉，新一點的瀏覽器才支援此功能:\nIE 10+, Chrome 43+, Firefox 41+, 及 Opera 29+');  
    //console.log('Oops, unable to copy');  
  }  

  // Remove the selections - NOTE: Should use
  // removeRange(range) when it is supported  
  window.getSelection().removeAllRanges(); 
};$(document).on('click', '#doCopy', fx.doCopyClicked);

$(function(){
	$('#myi').focus();

	$('#urlHere').autocomplete({
		source: appLinks
	});
});

var appLinks = <%=menuDP.toJSON()%>;
</script>
</head>
<body class='w3-light-gray w3-container'>
<div id="working" class="collapse" style="position:fixed; top:0; left:0; z-index:1000; " > 
  <div class="Snake"></div>
</div>
<div id="msg"></div>
<div>&nbsp;</div>
<div class="col-sm-6">
<form action="#" method="post" name="magic" class="table-condensed table-responsive" id="myForm">
	<div class="row">
    	<div class="col-sm-3 col-xs-6 black"><img src="lib.megic/test.ico" height="50"></div><!--
        --><div class="col-sm-9 col-xs-6 black"><span class="w3-large">Magic 任意門</span></div>
    </div>

    <div class="row" title="要使用此機制的人的人事代碼、中文名字也可以啦。">
    	<div class="col-sm-3 col-xs-6 black">使用者※</div><!--
        --><div class="col-sm-9 col-xs-6 black">
        <input tabindex="1" class="w3-padding w3-round" type="text" autocomplete="off" id="myi" name="i" style="width:99%" placeholder="可用 姓名、單位、學號、分機 快查。" /></div>
    </div>
    
    <div class="row">
    	<div class="col-sm-3 black">模擬對象</div><!--
        --><div class="col-sm-9 black">
        	<input tabindex="2" class="w3-padding w3-round" autocomplete="off" type="text" name="t" style="width:80%" placeholder="模擬成誰, 可快查。按加號(+) 可建立多位。" />
            <button type="button" name="bt3" class="w3-btn w3-ripple w3-round w3-border w3-margin-left" style="margin-left:3px;" title="可以增加多位模擬對象"> ＋ </button>
            </div>
    </div>
    <div id="clone" class="clone collapse"></div>
    <div class="row">
    	<div class="col-sm-3 black">測試網址※</div><!--
        --><div class="col-sm-9 black"><input tabindex="4" class="w3-padding w3-round" id="urlHere" autocomplete="off" type="text" name="u" placeholder="可快查，或從右邊清單點選。" style="width:99%"/></div>
    </div>
    <div class="row">
    	<div class="col-sm-3 col-xs-6 black">連結的有效天數※</div><!--
        --><div class="col-sm-9 col-xs-6 black"><input tabindex="5" class="w3-padding w3-round" type="number" name="d" value="7" style="width:20%" min="1" max="99"/> 最多99天
        </div>
    </div>
    <div class="row">
        <input type="hidden" name="act" value="DuoADream">
        <input type="hidden" name="gen" value="CYCU2942">
    	<div class="col-sm-3 col-xs-6 black"><button tabindex="8" type="reset" id="cancel" class="w3-btn w3-ripple w3-pale-red w3-round">Reset</button></div><!--
        --><div class="col-sm-9 col-xs-6 black"><button tabindex="6" type="button" id="accept" class="w3-btn w3-ripple w3-green w3-round">送出</button></div>
    </div>
</form>
<div id="dataHolder" class="w3-hide w3-white w3-round w3-card-4 w3-padding w3-margin-left"></div>
</div>

<div class="col-sm-6" id="urlmenu">
<table class="w3-table-all w3-hoverable w3-card">
    <tr>
        <th colspan="3" class="w3-right-align"><a href="https://itouch.cycu.edu.tw/active_project/cycu2500h_01/isms_sn/index.jsp" target="_blank">ISMS四階文件紀錄編號產生器</a></th>
       </tr>
    <tr>
        <th colspan="3" class="w3-right-align"><a href="http://140.135.68.115/CxWebClient/" target="_blank">Checkmarx源碼掃描 (admin@cx/admin)</a></th>
       </tr>
    <tr>
        <th colspan="3" class="w3-right-align"><a href="http://redmine.office.cycu.edu.tw:8080" target="_blank">Redmind報工時</a>、<a href="https://etouch30.cycu.edu.tw/cctimer/" target="_blank">計時小幫手</a></th>        
       </tr>
    <tr>
        <th colspan="3" class="w3-right-align">
        線上課程: <a target="_blank" href="https://hahow.in">hahow(migasun/cycuOOOO)</a>、<a target="_blank" href="https://www.udemy.com">udemy(migasun@gmail.com/cycuOOOO)</a>
        </th>
       </tr>
	<tr>
		<th colspan="3" class="w3-right-align">上線交換檔案區: <a href="\\svn2">\\svn2</a> 建構項目列表也在這裡 </th>
	</tr>
    <tr><th colspan="3" class="w3-right-align">iTouch登載的程式清單，點選可帶入URL至「測試網址」內。 <a href="./?force=1" target="_top">重新整理程式清單</a>
    <input id="filter001" tabindex="7" type="text" class="filter w3-input" placeholder="查詢任意欄位" autocomplete="off" >
    </th></tr>

<tbody class="class">
<%for(int i = 0 ; i < menuDP.size() ; i ++ ){ %>
<tr>
	<td class="q1"><%=menuDP.getString(i,"cname","") %></td>
	<td class="url"><%=menuDP.getString(i,"url","") %></td>
	<td class="memo"><%=menuDP.getString(i,"memo","") %></td>
</tr>
<%}//for dp %>
</tbody>
</table>
</div> 

<div id="diagQR">
	<div id="qrTitle"></div>
	<div id="qrcodeHere"></div>
</div>
</body>
</html>
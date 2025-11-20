<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
		<meta HTTP-EQUIV="Expires" CONTENT="-1">
		<link rel="shortcut icon" href="images/favicon.png">
		<link rel="icon" href="images/favicon.png">
		<title>AliyunDDNS</title>
		<link rel="stylesheet" type="text/css" href="index_style.css" />
		<link rel="stylesheet" type="text/css" href="form_style.css" />
		<link rel="stylesheet" type="text/css" href="usp_style.css" />
		<link rel="stylesheet" type="text/css" href="css/element.css">
		<link rel="stylesheet" type="text/css" href="res/softcenter.css">
		<script type="text/javascript" src="/state.js"></script>
		<script type="text/javascript" src="/popup.js"></script>
		<script type="text/javascript" src="/help.js"></script>
		<script type="text/javascript" src="/js/jquery.js"></script>
		<script type="text/javascript" src="/general.js"></script>
		<script type="text/javascript" language="JavaScript" src="/js/table/table.js"></script>
		<script type="text/javascript" language="JavaScript" src="/client_function.js"></script>
		<script type="text/javascript" src="/res/softcenter.js"></script>
		<style>
			.show_btn1,
			.show_btn2 {
				font-size: 10pt;
				color: #fff;
				padding: 4px 0;
				border-radius: 5px 5px 0px 0px;
				width: 10.42%;
				border-left: 1px solid #67767d61;
				border-top: 1px solid #67767d61;
				border-right: 1px solid #67767d61;
				border-bottom: none;
				background-color: transparent;
			}

			.show_btn1:hover:not(.active),
			.show_btn2:hover:not(.active) {
				background: #79797973;
			}

			.log_content {
				outline: 1px solid #222;
				width: 748px;
			}

			.log_content_text {
				width: 97%;
				padding-left: 4px;
				padding-right: 37px;
				font-family: "Lucida Console";
				font-size: 11px;
				line-height: 1.5;
				color: #9f9f9f;
				outline: none;
				overflow-x: hidden;
				border: 0px solid #222;
				background: #0d0b0c;
			}

			.ks_btn {
				border: 1px solid #222;
				font-size: 10pt;
				color: #fff;
				padding: 5px 5px 5px 5px;
				border-radius: 5px 5px 5px 5px;
				width: 14%;
				background: linear-gradient(to bottom, #003333 0%, #000000 100%);
			}

			.ks_btn:hover {
				border: 1px solid #222;
				font-size: 10pt;
				color: #fff;
				padding: 5px 5px 5px 5px;
				border-radius: 5px 5px 5px 5px;
				width: 14%;
				background: linear-gradient(to bottom, #27c9c9 0%, #279fd9 100%);
			}

			.input_option {
				vertical-align: middle;
				font-size: 12px;
			}

			input[type=button]:focus {
				outline: none;
			}
		</style>
		<script>
			var dbus = {};
			var responseLen;
			var x = 5;
			var toggleTimer = 0;
			var logTimer = 0;
			var actTimer = 0;
			var switchTimer = 0;
			var params = {
				enable: "aliyddnsv6_enable",
				restart: "aliyddnsv6_restart",
				inputs: ["aliyddnsv6_ak", "aliyddnsv6_sk", "aliyddnsv6_interval", "aliyddnsv6_ttl", "aliyddnsv6_comd", "aliyddnsv6_script1", "aliyddnsv6_script2", "aliyddnsv6_script3", "aliyddnsv6_script4", "aliyddnsv6_script5"],
				domain: "aliyddnsv6_domain",
				socat: "aliyddnsv6_socat",
				remove: {
					name: "aliyddnsv6_remove",
					value: null
				}
			}

			var skin = '<% nvram_get("sc_skin"); %>'; //ASUSWRT

			var popStyle = document.createElement("style");
			if (skin == "ROG"){
				popStyle.innerHTML = ".selectfolder{border-bottom:2px solid #91071f;}" + "\r\n" + ".active{background:#92A0A5;background:-moz-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#92A0A5 ),color-stop(100%,#66757C));background:-webkit-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-o-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-ms-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:linear-gradient(to bottom,#92A0A5 0%,#66757C 100%);background:#91071f;}";
			} else if (skin == "TUF"){
				popStyle.innerHTML = ".selectfolder{border-bottom:2px solid #92650F;}" + "\r\n" + ".active{background:#92A0A5;background:-moz-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#92A0A5 ),color-stop(100%,#66757C));background:-webkit-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-o-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-ms-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:linear-gradient(to bottom,#92A0A5 0%,#66757C 100%);background:#92650F;}";
			} else if (skin == "TS"){
				popStyle.innerHTML = ".selectfolder{border-bottom:2px solid #2ed9c3;}" + "\r\n" + ".active{background:#92A0A5;background:-moz-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#92A0A5 ),color-stop(100%,#66757C));background:-webkit-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-o-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-ms-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:linear-gradient(to bottom,#92A0A5 0%,#66757C 100%);background:#2ed9c3;}";
			} else {
				popStyle.innerHTML = ".selectfolder{border-bottom:2px solid #4d595d;}" + "\r\n" + ".active{background:#92A0A5;background:-moz-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#92A0A5 ),color-stop(100%,#66757C));background:-webkit-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-o-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:-ms-linear-gradient(top,#92A0A5 0%,#66757C 100%);background:linear-gradient(to bottom,#92A0A5 0%,#66757C 100%);}";
			}
			document.getElementsByTagName("head")[0].appendChild(popStyle);

			function init() {
				show_menu(menu_hook);
				generate_options();
				get_dbus_data(0);
			}

			function generate_options() {
				for (var i = 2; i <= 60; i++) {
					$("#aliyddnsv6_interval").append("<option value='" + i + "'>" + i + "</option>");
				}
				E("aliyddnsv6_interval").value = "5";
			}
			
			function trim(s) {//去空格
				return s&&s.replace(/(^\s*)|(\s*$)/g, "");
			}

			function config() {
				for (var i = 0; i < params.inputs.length; i++) {
					dbus[params.inputs[i]] ? E(params.inputs[i]).value = dbus[params.inputs[i]] : null;
					dbus[params.inputs[i]] && params.inputs[i].substring(0, 17)=="aliyddnsv6_script" ? (E("aliyddnsv6_extend").options[params.inputs[i].substring(17, 18)-1].innerHTML = "指令"+params.inputs[i].substring(17, 18)):null;
				}
				E("aliyddnsv6_extend").value = "1", changeExtendSelect(E("aliyddnsv6_extend").options[0]);

				if (typeof (dbus[params.domain]) != "undefined") {
					var maxLength = $("#tbody_3").attr("max");
					var t = dbus[params.domain].split(";");
					for (var i = 0; i < t.length; i++) {
						var temp = t[i].split(",");
						var html = '<td>'
								 + '<input type="text" class="input_ss_table" style="width:90px" placeholder="子域名" value="' + temp[0] + '" onBlur="checkRR(this);" autocorrect="off" autocapitalize="off" autocomplete="off" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 42||event.keyCode == 46||event.keyCode == 64||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" />'
								 + '<span style="margin:0 3px">.</span>'
								 + '<input type="text" class="input_ss_table" style="width:175px" placeholder="主域名" value="' + temp[1] + '" onBlur="checkDomain(this);" autocorrect="off" autocapitalize="off" autocomplete="off" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 46||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" />'
								 + '<select class="input_option" style="margin:0px 0px 0px 8px;">'
								 + '<option value="0"' + (temp[2]=='0'||!checkExtendSelect(temp[2])?' selected':'') + '>默认方式</option><option value="1"' + (checkExtendSelect(1)?(temp[2]=='1'?' selected':''):' disabled') + '>扩展指令1</option><option value="2"' + (checkExtendSelect(2)?(temp[2]=='2'?' selected':''):' disabled') + '>扩展指令2</option><option value="3"' + (checkExtendSelect(3)?(temp[2]=='3'?' selected':''):' disabled') + '>扩展指令3</option><option value="4"' + (checkExtendSelect(4)?(temp[2]=='4'?' selected':''):' disabled') + '>扩展指令4</option><option value="5"' + (checkExtendSelect(5)?(temp[2]=='5'?' selected':''):' disabled') + '>扩展指令5</option>'
								 + '</select>'
								 + '<input type="hidden" class="input_ss_table" value="' + temp[3] + '">'
								 + '<div style="min-width:70px;margin:-2px 0px -12px 0px;float:right">'
								 + '<input type="button" class="add_btn" style="visibility:hidden;" tabindex="-1" onclick="addDomainRow(this);">'
								 + '<input type="button" class="remove_btn" tabindex="-1" onclick="delDomainRow(this);">'
								 + '</div>'
								 + '</td>';
						$("#tbody_3").append("<tr>"+html+"</tr>");
					}
					t.length == 0 && addDomainRow();
					t.length < maxLength && $("#tbody_3").find(".add_btn:last").css("visibility", "visible");
				} else {
					addDomainRow();
				}

				if (typeof (dbus[params.socat]) != "undefined") {
					var maxLength = $("#tbody_4").attr("max");
					var t = dbus[params.socat].split(";");
					for (var i = 0; i < t.length ; i++) {
						var temp = t[i].split(",");
						var html = '<td>'
								 + '<input type="text" class="input_15_table" placeholder="名称" value="' + temp[0] + '" maxlength="12" onKeypress="javascript:event.returnValue=((event.keyCode >= 65 && event.keyCode <= 90)||(event.keyCode >= 97 && event.keyCode <= 122))?true:false;" />'
								 + '</td><td>'
								 + '<select class="input_option">'
								 + '<option value="2"' + (temp[1]==2?' selected':'') + '>IPv6</option><option value="1"' + (temp[1]==1?' selected':'') + '>IPv4</option><option value="3"' + (temp[1]==3?' selected':'') + '>IPv64</option>'
								 + '</select>'
								 + '</td><td>'
								 + '<input type="text" class="input_15_table" placeholder="端口号" value="' + temp[2] + '" maxlength="5" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)?true:false;" />'
								 + '</td><td>'
								 + '<input type="text" class="input_15_table" placeholder="端口号" value="' + temp[3] + '" maxlength="5" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)?true:false;" />'
								 + '</td><td>'
								 + '<input type="text" class="input_15_table" placeholder="IPv4地址" value="' + temp[4] + '" maxlength="15" onKeypress="javascript:event.returnValue=((event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 46)?true:false;" />'
								 + '</td><td>'
								 + '<div style="min-width:70px;height:32px;">'
								 + '<input type="button" class="add_btn" style="visibility:hidden;" tabindex="-1" onclick="addSocatRow(this);" value="">'
								 + '<input type="button" class="remove_btn" tabindex="-1" onclick="delSocatRow(this);" value="">'
								 + '</div>'
								 + '</td>';
						$("#tbody_4").append("<tr>"+html+"</tr>");
					}
					t.length == 0 && addSocatRow();
					t.length < maxLength && $("#tbody_4").find(".add_btn:last").css("visibility", "visible");
				} else {
					addSocatRow();
				}

				E(params.enable).checked = (dbus[params.enable]=="1")||false;
				E(params.restart).checked = (dbus[params.restart]=="1")||false;
				if (dbus["aliyddnsv6_version"]){
					E("aliyddnsv6_version").innerHTML = "当前版本：" + dbus["aliyddnsv6_version"]
				}
			}

			function get_dbus_data(flag) {
				$.ajax({
					type: "GET",
					url: "/_api/aliyddnsv6",
					dataType: "json",
					cache: false,
					async: false,
					success: function (data) {
						dbus = data.result[0];
						//clearInterval(actTimer); //屏蔽状态标签时钟
						if (dbus[params.enable] == "1"){
							get_run_status();
							//actTimer = setInterval("get_run_status();", 10000); //屏蔽状态标签时钟
							if (dbus["aliyddnsv6_ipv4"] && dbus["aliyddnsv6_ipv6"]){
								E("wlan_ip").innerHTML = "IPv4：" + dbus["aliyddnsv6_ipv4"] + "<br>" + "IPv6：" + dbus["aliyddnsv6_ipv6"];
							} else if (dbus["aliyddnsv6_ipv4"]){
								E("wlan_ip").innerHTML = "IPv4：" + dbus["aliyddnsv6_ipv4"]
							} else if (dbus["aliyddnsv6_ipv6"]){
								E("wlan_ip").innerHTML = "IPv6：" + dbus["aliyddnsv6_ipv6"]
							} else {
								E("wlan_ip").innerHTML = "获取失败"
							}
							flag == 1 && checkRecordId();
						} else {
							E("run_status").innerHTML = "Loading...";
							E("wlan_ip").innerHTML = "";
						}
						if (flag == 0){
							config();
							toggle_func();
							update_visibility();
							hook_event();
							change_url();
						}
					},
					error: function (XmlHttpRequest, textStatus, errorThrown) {
						alert("数据读取错误，即将退出登录");
						location = "Logout.asp"; //退出登录
					}
				});
			}

			function change_url() {
				var http = '<% nvram_get("misc_http_x"); %>';
				var httpPort = '<% nvram_get("misc_httpsport_x"); %>';
				var httpHostname = '<% nvram_get("ddns_hostname_x"); %>';

				if (http == "0"){
					E("wan_access_url").innerHTML = "检测到【从互联网设置 <% nvram_get("productid"); %>】未启用，请前往<a href=" + "/Advanced_System_Content.asp" + "><em><u>系统管理 -系统设置</u></em></a>页面设置！";
				}else if (httpHostname.length != 0 && E(params.enable).checked == true){
					E("wan_access_url").innerHTML = "&nbsp;DDNS远程访问地址：<a href=\"https://" + httpHostname + ":" + httpPort + "\" target=\"_blank\" style=\"color:#00ffe4;text-decoration: underline; font-family:Lucida Console;\"><em>https://" + httpHostname + ":" + httpPort + "</em></a></em>";
				}
			}

			function get_run_status() {
				$.ajax({
					type: "GET",
					url: "/_api/aliyddnsv6_last_act",
					dataType: "json",
					async: true,
					cache: false,
					success: function (data) {
						if (data.result[0].hasOwnProperty("aliyddnsv6_last_act")) {
							E("run_status").innerHTML = data.result[0]["aliyddnsv6_last_act"];
						}
					},
					error: function (xhr) {
						E("run_status").innerHTML = "获取失败";
					}
				});
			}

			function checkRR(domainInput){
				if(domainInput.value == "") domainInput.value = "@";
			}
			
			function checkDomain(domainInput){
				var node = domainInput.parentNode;
			}
			
			function checkRecordId(domain){
				var domainArray = dbus[params.domain].split(";");
				var domainTds = $("#tbody_3").find("td");
				if (domainArray.length == domainTds.length){
					for (var i = 0; i < domainArray.length; i++){
						var domains = domainArray[i].split(",");
						var inputs = $(domainTds[i]).find("input.input_ss_table,select.input_option");
						if (domains.length == 4 && domains.length == inputs.length){
							inputs[0].value == domains[0] && inputs[1].value == domains[1] && $(inputs[3]).val(domains[3]);
						}
					}
				}
			}

			function checkTable3(){ // 检查域名区域
				var domainInputs = $("#tbody_3").find(":text");
				var domainText = "";
				for (var i = 0; i < domainInputs.length; i+=2){
					if (trim(domainInputs.eq(i).val()) == ""){
						domainInputs.eq(i).focus();
						return false;
					} else if(trim(domainInputs.eq(i+1).val()) == ""){
						domainInputs.eq(i+1).focus();
						return false;
					} else {
						var text = trim(domainInputs.eq(i).val()) + "." + trim(domainInputs.eq(i+1).val()) + ";";
						if (domainText.indexOf(text) >= 0){
							domainInputs.eq(i).focus();
							return false;
						}
						domainText += text;
					}
				}
				return true;
			}
			
			function checkTable4(){ //检查转发区域
				var socatInputs = $("#tablet_4").find(":text");
				var socatText = "";
				for (var i = 0; i < socatInputs.length; i+=4){
					if (trim(socatInputs.eq(i).val()) == ""){
						socatInputs.eq(i).focus();
						return false;
					} else if(trim(socatInputs.eq(i+1).val()) == ""){
						socatInputs.eq(i+1).focus();
						return false;
					} else if(trim(socatInputs.eq(i+2).val()) == ""){
						socatInputs.eq(i+2).focus();
						return false;
					} else if(trim(socatInputs.eq(i+3).val()) == ""){
						socatInputs.eq(i+3).focus();
						return false;
					} else {
						var name = "name:" + trim(socatInputs.eq(i).val()) + ",";
						var wai = "wai:" + trim(socatInputs.eq(i+1).val()) + ",";
						var nei = "nei:" + trim(socatInputs.eq(i+2).val()) + ",ip:" + trim(socatInputs.eq(i+3).val()) + ";"
						if (socatText.indexOf(name) >= 0){
							socatInputs.eq(i).focus();
							return false;
						} else if (socatText.indexOf(wai) >= 0){
							socatInputs.eq(i+1).focus();
							return false;
						} else if (socatText.indexOf(nei) >= 0){
							socatInputs.eq(i+2).focus();
							return false;
						}
						socatText += name + wai + nei;
					}
				}
				return true;
			}

			function checkForm(flag){ //[1]提交 [2]清除
				if (flag == 1){ //提交
					if (E(params.enable).checked){
						if (E("aliyddnsv6_ak").value == ""){
							E("aliyddnsv6_ak").focus();
							return false;
						} else if (E("aliyddnsv6_sk").value == ""){
							E("aliyddnsv6_sk").focus();
							return false;
						}
						return checkTable3() && checkTable4();
					} else if (dbus[params.enable] == "1"){
						return true;
					} else {
						return false;
					}
				} else if (flag == 2) { //清除
					return responseLen > 1;
				} else {
					return false;
				}
			}

			function save(flag) { //[1]提交 [2]清除 [3]移除(其他地方)
				var new_dbus = {}
				if(!checkForm(flag)) return false;
				flag == 1 && clearTimeout(switchTimer);
				if (flag == 1){
					var domainInputs = $("#tbody_3").find("input.input_ss_table,select.input_option"); // 获取域名区域所有文本框
					var domains = "";
					for (var i = 0; i < domainInputs.length; i+=4) {
						if (trim(domainInputs.eq(i).val()) != "" && trim(domainInputs.eq(i + 1).val()) != "") {
							domains += trim(domainInputs.eq(i).val()) + "," + trim(domainInputs.eq(i + 1).val()) + "," + trim(domainInputs.eq(i + 2).val()) + "," + trim(domainInputs.eq(i + 3).val()) + ";";
						}
					}
					
					var socatInputs = $("#tablet_4").find("input.input_15_table,select.input_option"); // 获取转发区域所有文本框
					var socats = "";
					for (var i = 0; i < socatInputs.length; i+=5) {
						socats += trim(socatInputs.eq(i).val()) + "," + trim(socatInputs.eq(i + 1).val()) + "," + trim(socatInputs.eq(i + 2).val()) + "," + trim(socatInputs.eq(i + 3).val()) + "," + trim(socatInputs.eq(i + 4).val()) + ";";
					}
					for (var i = 0; i < params.inputs.length; i++) {
						new_dbus[params.inputs[i]] = E(params.inputs[i]).value;
					}
					new_dbus[params.enable] = E(params.enable).checked ? "1" : "0";
					new_dbus[params.restart] = E(params.restart).checked ? "1" : "0";
					new_dbus[params.domain] = domains.substring(0, domains.length - 1);
					new_dbus[params.socat] = socats.substring(0, socats.length - 1);
					if (!!params.remove.value) new_dbus[params.remove.name] = params.remove.value;
				}
				$("#show_btn2").trigger("click");
				E("log_content_text").scrollTop = E("log_content_text").scrollHeight;

				var id = parseInt(Math.random() * 100000000);
				var postData = { "id": id, "method": "aliyddnsv6_config.sh", "params": [flag], "fields": new_dbus };

				!0 && $.ajax({
					url: "/_api/",
					cache: false,
					async: flag==1,
					type: "POST",
					dataType: "json",
					data: JSON.stringify(postData),
					success: function (response) {
						//var result = JSON.parse(response.result.toString().replace(/\/'/g, '"'));
						if (response.result == id) {
							if(flag == 1) params.remove.value = null;
							get_log(1);
							flag == 1 && get_dbus_data(1);
							if (E(params.enable).checked) {
								if ($("#show_btn2").hasClass("active")){
									var tbodys = $("#tbody_3").find("td");
									var trs = $("#tbody_4").find("tr");
									flag == 1 && clearTimeout(toggleTimer);
									flag == 1 ? toggleTimer = setTimeout("$('#show_btn1').trigger('click');", 3000+((tbodys?tbodys.length:0)+(trs?(trs.length-1):0))*1500) : null;
								}
							} else {
								clearTimeout(toggleTimer);
								switchTimer = setTimeout(function(){
									clearTimeout(logTimer);
									E("tablet_1").style.display = "none";
									E("tablet_2").style.display = "none";
									E("apply_button").setAttribute("onclick", "save(1)");
									E("apply_button").value = "提 交";
								}, 8000)
							}
						}
					}
				}); 
			}

			function hook_event() {
				$("#aliyddnsv6_enable").click(
					function () {
						if (E(params.enable).checked) {
							clearTimeout(switchTimer);
							$("#show_btn1").addClass("active");
							$("#show_btn2").removeClass("active");
							E("tablet_show").style.display = "";
							E("last_act_tr").style.display = "";
							E("wlan_ipaddr").style.display = "";
							E("svr_restart").style.display = "";
							E("tablet_1").style.display = "";
							E("tablet_2").style.display = "none";
							E("tablet_3").style.display = "";
							E("tablet_4").style.display = "";
							E("apply_button").setAttribute("onclick", "save(1)");
							E("apply_button").value = "提 交";
						} else {
							clearTimeout(toggleTimer);
							$("#show_btn1").removeClass("active");
							$("#show_btn2").removeClass("active");
							E("tablet_show").style.display = "none";
							E("last_act_tr").style.display = "none";
							E("wlan_ipaddr").style.display = "none";
							E("svr_restart").style.display = "none";
							E("tablet_1").style.display = "none";
							E("tablet_2").style.display = "none";
							E("tablet_3").style.display = "none";
							E("tablet_4").style.display = "none";
							E("apply_button").setAttribute("onclick", "save(1)");
							E("apply_button").value = "提 交";
						}
					}
				);
			}

			function get_log(flag) {
				$.ajax({
					url: "/_temp/aliyddnsv6_log.txt",
					type: "GET",
					dataType: "html",
					async: true,
					cache: false,
					success: function (response) {
						var retArea = E("log_content_text");
						retArea.value = response;
						responseLen = response.length;
						flag > 0 || (isMobile() ? 72 : 54) >= (retArea.scrollHeight - retArea.scrollTop - retArea.clientHeight) ? retArea.scrollTop = retArea.scrollHeight : null;
						//areaLen = retArea.getAttribute("length");
						//responseLen > areaLen ? (retArea.scrollTop = retArea.scrollHeight, retArea.setAttribute("length", responseLen)) : null; //有新内容强制滚动
						clearTimeout(logTimer);
						logTimer = setTimeout("get_log(0);", 1500);
					},
					error: function (xhr) {
						clearTimeout(logTimer);
						logTimer = setTimeout("get_log(0);", 5000);
					}
				});
			}

			function toggle_func() {
				$("#show_btn1").addClass("active");
				$("#show_btn1").click(
					function () {
						clearTimeout(toggleTimer);
						$("#show_btn1").addClass("active");
						$("#show_btn2").removeClass("active");
						E("tablet_1").style.display = "";
						E("tablet_2").style.display = "none";
						E("tablet_3").style.display = "";
						E("tablet_4").style.display = "";
						E("apply_button").setAttribute("onclick", "save(1)");
						E("apply_button").value = "提 交";
					}
				);
				$("#show_btn2").click(
					function () {
						$("#show_btn1").removeClass("active");
						$("#show_btn2").addClass("active");
						E("tablet_1").style.display = "none";
						E("tablet_2").style.display = "";
						E("tablet_3").style.display = "none";
						E("tablet_4").style.display = "none";
						E("apply_button").setAttribute("onclick", "save(2)");
						E("apply_button").value = "清 除";
						get_log(1);
					}
				);
			}

			function update_visibility() {
				if (E(params.enable).checked) {
					E("tablet_show").style.display = "";
					E("last_act_tr").style.display = "";
					E("wlan_ipaddr").style.display = "";
					E("svr_restart").style.display = "";
					E("tablet_1").style.display = "";
					E("tablet_3").style.display = "";
					E("tablet_4").style.display = "";
				} else {
					E("tablet_show").style.display = "none";
					E("last_act_tr").style.display = "none";
					E("wlan_ipaddr").style.display = "none";
					E("svr_restart").style.display = "none";
					E("tablet_1").style.display = "none";
					E("tablet_3").style.display = "none";
					E("tablet_4").style.display = "none";
				} 
			}

			function menu_hook() {
				tabtitle[tabtitle.length - 1] = new Array("", "aliyddnsv6");
				tablink[tablink.length - 1] = new Array("", "Module_aliyddnsv6.asp");
			}

			function reload_Soft_Center() {
				location.href = "/Module_Softcenter.asp";
			}
			function checkExtendSelect(index) {
				return E("aliyddnsv6_script"+index) ? E("aliyddnsv6_script"+index).value.length>0 : true;
			}
			function changeExtendSelect(obj) {
				E("aliyddnsv6_script").value = (window.atob && window.atob(E("aliyddnsv6_script"+$(obj).val()).value)||"");
			}
			function saveExtendScript(obj) {
				obj.value = obj.value.trim();
				var index = E("aliyddnsv6_extend").value;
				if(obj.value.length != E("aliyddnsv6_script"+index).value.length) {
					E("aliyddnsv6_loading").style.display = "";
					setTimeout(function(){
						E("aliyddnsv6_loading").style.display = "none";
					}, 300);
				}

				E("aliyddnsv6_extend").options[index-1].innerHTML = "指令" + (obj.value.length ? index:"(空)");
				E("aliyddnsv6_script"+index).value = (obj.value.length && window.btoa && window.btoa(obj.value))||"";
				var scriptSelect = $("#tablet_3").find("select.input_option")
				for (var i = 0; i < scriptSelect.length; i++){
					if(obj.value == ""){
						$(scriptSelect[i]).val() == index && $(scriptSelect[i]).val("0");
						$(scriptSelect[i]).find("option").eq(index).attr("disabled", true).removeAttr("selected");
					} else {
						$(scriptSelect[i]).find("option").eq(index).removeAttr("disabled");
					}
				}
			}

			function addDomainRow(obj) {
				if(!checkTable3()) return;
				var maxLength = $("#tbody_3").attr("max");
				var node = obj && obj.parentNode.parentNode.parentNode.parentNode;
				if(node && node.rows.length>maxLength) return;
				var html = '<tr><td>'
						 + '<input type="text" class="input_ss_table" style="width:90px" placeholder="子域名" value="" onBlur="checkRR(this);" autocorrect="off" autocapitalize="off" autocomplete="off" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 42||event.keyCode == 46||event.keyCode == 64||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" />'
						 + '<span style="margin:0 3px">.</span>'
						 + '<input type="text" class="input_ss_table" style="width:175px" placeholder="主域名" value="" onBlur="checkDomain(this);" autocorrect="off" autocapitalize="off" autocomplete="off" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 46||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" />'
						 + '<select class="input_option" style="margin:0px 0px 0px 8px;">'
						 + '<option value="0" selected="selected">默认方式</option><option value="1"' + (checkExtendSelect(1)?'':' disabled') + '>扩展指令1</option><option value="2"' + (checkExtendSelect(2)?'':' disabled') + '>扩展指令2</option><option value="3"' + (checkExtendSelect(3)?'':' disabled') + '>扩展指令3</option><option value="4"' + (checkExtendSelect(4)?'':' disabled') + '>扩展指令4</option><option value="5"' + (checkExtendSelect(5)?'':' disabled') + '>扩展指令5</option>'
						 + '</select>'
						 + '<input type="hidden" class="input_ss_table" value="">'
						 + '<div style="width:68px;margin:-2px 0px -12px 0px;float:right">'
						 + '<input type="button" class="add_btn" tabindex="-1" onclick="addDomainRow(this);">'
						 + '<input type="button" class="remove_btn" tabindex="-1" onclick="delDomainRow(this);">'
						 + '</div>'
						 + '</td>';
				$("#tbody_3").append(html);
				obj && $(obj).css("visibility", "hidden") && checkTable3();
				node && node.rows.length > maxLength && $("#tbody_3").find(".add_btn:last").css("visibility", "hidden");
			}
			function delDomainRow(obj) {
				var node = obj.parentNode.parentNode.parentNode.parentNode;
				var domainInputs = $(obj.parentNode.parentNode).find("input.input_ss_table");
				if(domainInputs.length == 3 && trim(domainInputs.eq(2).val()) != ""){
					if (!params.remove.value){
						params.remove.value = domainInputs[2].value + "," + domainInputs[0].value + "," + domainInputs[1].value;
					} else {
						params.remove.value += ";" + domainInputs[2].value + "," + domainInputs[0].value + "," + domainInputs[1].value;
					}
				}
				node.rows.length==2 && $(node).find("input:text").val("") && $(node).find("select").val("0") && $(node).find("input:hidden").val("");
				node.rows.length>2 && node.removeChild(obj.parentNode.parentNode.parentNode);
				$(node).find(".add_btn:last").css("visibility", "visible");
			}

			function addSocatRow(obj) {
				if(!checkTable4()) return;
				var maxLength = $("#tbody_4").attr("max");
				var node = obj && obj.parentNode.parentNode.parentNode.parentNode;
				if(node && node.rows.length>maxLength) return;
				var html = '<tr><td>'
						 + '<input type="text" class="input_15_table" placeholder="名称" value="" maxlength="12" onKeypress="javascript:event.returnValue=((event.keyCode >= 65 && event.keyCode <= 90)||(event.keyCode >= 97 && event.keyCode <= 122))?true:false;" />'
						 + '</td><td>'
						 + '<select class="input_option">'
						 + '<option value="2" selected>IPv6</option><option value="1">IPv4</option><option value="3">IPv64</option>'
						 + '</select>'
						 + '</td><td>'
						 + '<input type="text" class="input_15_table" placeholder="端口号" value="" maxlength="5" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)?true:false;" />'
						 + '</td><td>'
						 + '<input type="text" class="input_15_table" placeholder="端口号" value="" maxlength="5" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)?true:false;" />'
						 + '</td><td>'
						 + '<input type="text" class="input_15_table" placeholder="IPv4地址" value="" maxlength="15" onKeypress="javascript:event.returnValue=((event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 46)?true:false;" />'
						 + '</td><td>'
						 + '<div style="min-width:70px;height:32px;">'
						 + '<input type="button" class="add_btn" tabindex="-1" onclick="addSocatRow(this);" value="">'
						 + '<input type="button" class="remove_btn" tabindex="-1" onclick="delSocatRow(this);" value="">'
						 + '</div>'
						 + '</td></tr>';
				$("#tbody_4").append(html);
				obj && $(obj).css("visibility", "hidden") && checkTable4();
				node && node.rows.length > maxLength && $("#tbody_4").find(".add_btn:last").css("visibility", "hidden");
			}

			function delSocatRow(obj) {
				var node = obj.parentNode.parentNode.parentNode.parentNode;
				node.rows.length==2 && $(node).find("input:text").val("");
				node.rows.length>2 && node.removeChild(obj.parentNode.parentNode.parentNode);
				$(node).find(".add_btn:last").css("visibility", "visible");
			}

			function isMobile() {
				var userAgent = navigator.userAgent;
				var Agents = ["Harmony", "Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod"];
				var flag = false;
				for (var i = 0; i < Agents.length; i++) {
					if (userAgent.indexOf(Agents[i]) > 0) {
						flag = true;
						break;
					}
				}
				return flag;
			}
		</script>
	</head>

	<body onload="init();">
		<div id="TopBanner"></div>
		<div id="Loading" class="popup_bg"></div>
		<table class="content" align="center" cellpadding="0" cellspacing="0">
			<tr>
				<td width="17">&nbsp;</td>
				<td valign="top" width="202">
					<div id="mainMenu"></div>
					<div id="subMenu"></div>
				</td>
				<td valign="top">
					<div id="tabMenu" class="submenuBlock"></div>
					<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0" style="display: block;">
						<tr>
							<td align="left" valign="top">
								<div>
									<table class="FormTitle" width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3">
										<tr>
											<td bgcolor="#4D595D" colspan="3" valign="top">
												<div>&nbsp;</div>
												<div class="formfonttitle" style="float:left;">AliyunDDNS</div>
												<div style="float:right; width:15px; height:25px;margin-top:10px">
													<img onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
												</div>
												<div class="splitLine" style="margin:30px 0 10px 5px;"></div>
												<div style="margin-left:5px;">
													<li><em>AliyunDDNS</em>是一款基于阿里云动态域名解析的私有云解决方案，同时兼容IPv6及IPv4地址。</li>
												</div>
												<div style="margin:5px 0px 0px 0px;">
													<table class="FormTable" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
														<thead>
															<tr>
																<td colspan="2">DDNS - 服务状态</td>
															</tr>
														</thead>
														<tr id="switch_tr">
															<th>
																<label>开启DDNS服务</label>
															</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell">
																	<label for="aliyddnsv6_enable">
																		<input id="aliyddnsv6_enable" class="switch" type="checkbox" style="display:none;" />
																		<div class="switch_container">
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div id="aliyddnsv6_version" style="padding-top:5px;margin-right:30px;margin-top:-30px;float:right;"></div>
															</td>
														</tr>
														<tr id="last_act_tr" style="display:none;">
															<th>运行状态</th>
															<td>
																<span id="run_status"></span>
															</td>
														</tr>
														<tr id="wlan_ipaddr" style="display:none;">
															<th>IP地址</th>
															<td>
																<span id="wlan_ip" style="display:inline-block;word-break:normal;line-height:1.2em;"></span>
															</td>
														</tr>
														<tr id="svr_restart" style="display:none;">
															<th style="cursor:help;" title="当设备重启或断开时允许强制启动服务">服务进程守护</th>
															<td>
																<input type="checkbox" id="aliyddnsv6_restart" style="vertical-align:middle;" />
															</td>
														</tr>
													</table>
												</div>
												<div id="tablet_show" style="display:none;">
													<table class="selectfolder" style="margin:10px 0px 0px 0px;border-collapse:collapse;" width="100%" height="32px">
														<tr>
															<td cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#222">
																<input id="show_btn1" class="show_btn1" style="cursor:pointer" type="button" value="服务配置" />
																<input id="show_btn2" class="show_btn2" style="cursor:pointer" type="button" value="查看日志" />
															</td>
														</tr>
													</table>
												</div>
												<div id="tablet_1" style="display:none;">
													<table class="FormTable" width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
														<tr>
															<th style="cursor:help;" title="阿里云控制台获取">Ali Access Key ID</th>
															<td>
																<input type="text" id="aliyddnsv6_ak" placeholder="Access Key ID" class="input_ss_table" style="width:260px;" autocomplete="off" autocorrect="off" autocapitalize="off" maxlength="100" spellcheck="false" readonly onFocus="this.removeAttribute('readonly');" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||(event.keyCode >= 65 && event.keyCode <= 90)||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" onkeyup="this.value=this.value.replace(/[\W]/g,'')" />
															</td>
														</tr>
														<tr>
															<th style="cursor:help;" title="阿里云控制台获取">Ali Access Key Secret</th>
															<td>
																<input type="password" id="aliyddnsv6_sk" placeholder="Access Key Secret" class="input_ss_table" style="width:260px;" autocomplete="off" autocorrect="off" autocapitalize="off" maxlength="100" spellcheck="false" readonly onBlur="switchType(this, false);" onFocus="switchType(this, true);this.removeAttribute('readonly');" onKeypress="javascript:event.returnValue=(event.keyCode >= 48 && event.keyCode <= 57)||(event.keyCode >= 65 && event.keyCode <= 90)||(event.keyCode >= 97 && event.keyCode <= 122)?true:false;" onkeyup="this.value=this.value.replace(/[\W]/g,'')" />
															</td>
														</tr>
														<tr>
															<th style="cursor:help;" title="检查域名解析周期">检查时钟周期</th>
															<td>
																<select style="width:45px;margin:0px 0px 0px 2px;" id="aliyddnsv6_interval" class="input_option"></select> min
															</td>
														</tr>
														<tr>
															<th style="cursor:help;" title="获取IP类型选择&#10;IPv6 or IPv4">获取IP默认方式</th>
															<td>
																<select style="width:12em;margin:0px 0px 0px 2px;" id="aliyddnsv6_comd" class="input_option">
																	<option value="0" selected="selected">PPPoE-IPv6</option>
																	<option value="1">PPPoE-IPv4</option>
																	<option value="2">v6.ip.zxinc.org</option>
																	<option value="3">v6.meibu.com</option>
																</select>
															</td>
														</tr>
														<tr>
															<th style="cursor:help;" title="通过添加自定义脚本指令来获取IP方式&#10;记得按Enter键保存">扩展获取IP方式管理</th>
															<td>
																<select style="width:6em;margin:0px 0px 0px 2px;" id="aliyddnsv6_extend" class="input_option" onchange="changeExtendSelect(this);">
																	<option value="1">指令(空)</option>
																	<option value="2">指令(空)</option>
																	<option value="3">指令(空)</option>
																	<option value="4">指令(空)</option>
																	<option value="5">指令(空)</option>
																</select>
																<input id="aliyddnsv6_script" class="input_option input_ss_table" style="width:29.5em; margin:0px 0px 0px 8px;" placeholder="自定义脚本指令获取IP，按Enter键保存" onBlur="" onkeydown="javascript:if(event.keyCode==13) saveExtendScript(this);" />
																<img id="aliyddnsv6_loading" class="input_option" style="width:18px; height:18px; background-color:transparent; display:none;" src="images/InternetScan.gif">
																<input id="aliyddnsv6_script1" type="hidden" value="" />
																<input id="aliyddnsv6_script2" type="hidden" value="" />
																<input id="aliyddnsv6_script3" type="hidden" value="" />
																<input id="aliyddnsv6_script4" type="hidden" value="" />
																<input id="aliyddnsv6_script5" type="hidden" value="" />
															</td>
														</tr>
														<tr>
															<th style="cursor:help;" title="设置解析时间，默认600s">TTL解析时间</th>
															<td>
																<input id="aliyddnsv6_ttl" class="input_ss_table" style="width:4.5em" value="600"  autocorrect="off" autocapitalize="off" autocomplete="off"  onblur="javascript:this.value<600?this.value=600:this.value>86400?this.value=86400:null;" />
																s (600~86400)
															</td>
														</tr>
														<tr id="url_tr">
															<th>远程访问地址</th>
															<td><span id="wan_access_url" style="text-align:left;"></span>
															</td>
														</tr>
													</table>
												</div>
												<div id="tablet_2" style="display:none;">
													<div class="log_content" style="margin-top:2px;display:block;overflow:hidden;">
														<textarea id="log_content_text" class="log_content_text" cols="63" rows="23" wrap="on" readonly="readonly" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
													</div>
												</div>
												<div id="tablet_3" style="margin:5px 0px 0px 0px; display:none;">
													<table class="FormTable" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
														<thead>
															<tr>
																<td colspan="5">DDNS - 解析列表</td>
															</tr>
														</thead>
														<tbody id="tbody_3" max="5">
															<tr>
																<th style="cursor:help;" title="*  代表www&#10;@代表主域名" rowspan="6">域名</th>
															</tr>
														</tbody>
													</table>
												</div>
												<div id="tablet_4" style="margin:5px 0px 0px 0px; display:none;">
													<table class="FormTable" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
														<thead>
															<tr>
																<td colspan="6">DDNS - 转发列表</td>
															</tr>
														</thead>
														<tbody id="tbody_4" class="FormTable_table" max="5">
															<tr>
																<th>自定义名称</th>
																<th style="cursor:help;" title="转发类型&#10;IPv6表示转发仅来至IPv6的来源请求&#10;IPv4表示转发仅来至IPv4的来源请求&#10;IPv64包含以上两者">转发类型</th>
																<th>外部端口</th>
																<th>内部端口</th>
																<th>本地IPv4地址</th>
																<th>操作</th>
															</tr>
														</tbody>
													</table>
												</div>
												<div id="apply_gen" class="apply_gen">
													<input id="apply_button" class="button_gen" type="button" onclick="save(1)" value="提 交" />
												</div>
											</td>
										</tr>
									</table>
								</div>
							</td>
						</tr>
					</table>
				</td>
				<td width="10" align="center" valign="top"></td>
			</tr>
		</table>
		<div id="footer"></div>
	</body>
</html>
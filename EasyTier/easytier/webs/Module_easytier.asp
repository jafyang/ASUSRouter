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
		<title>EasyTier</title>
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
				enable: "easytier_enable",
				version: "easytier_core",
				status: "easytier_status",
				watchdog: "easytier_watchdog",
				id: "easytier_id"
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
				get_dbus_data();
				hook_event();
			}
			
			function trim(s) {//去空格
				return s&&s.replace(/(^\s*)|(\s*$)/g, "");
			}

			function get_dbus_data() {
				$.ajax({
					type: "GET",
					url: "/_api/easytier",
					dataType: "json",
					cache: false,
					async: false,
					success: function (data) {
						dbus = data.result[0];
						console.log(dbus);
						E(params.enable).checked = (dbus[params.enable]=="1")||false;
						E(params.version).innerHTML = dbus[params.version] || "*";
						E(params.status).innerHTML = dbus[params.status] || "未运行";
						E(params.watchdog).checked = (dbus[params.watchdog]=="1")||false;
						E(params.id).value = dbus[params.id]||"";
						update_visibility();
					},
					error: function (XmlHttpRequest, textStatus, errorThrown) {
						alert("数据读取错误，即将退出登录");
						location = "Logout.asp"; //退出登录
					}
				});
			}

			function save() {
				if(E(params.enable).checked && E(params.id).value == ""){
					E(params.id).focus();
					return false;
				}
				var new_dbus = {}
				new_dbus[params.enable] = E(params.enable).checked ? "1" : "0";
				new_dbus[params.watchdog] = E(params.enable).checked && E(params.watchdog).checked ? "1" : "0";
				new_dbus[params.id] = E(params.id).value;
				var id = parseInt(Math.random() * 100000000);
				var postData = { "id": id, "method": "easytier_config.sh", "params": [1], "fields": new_dbus };

				!0 && $.ajax({
					url: "/_api/",
					cache: false,
					async: true,
					type: "POST",
					dataType: "json",
					data: JSON.stringify(postData),
					beforeSend: function(){
						LoadProgress(); //显示进度
					},
					success: function (response) {
						if (response.result == id) {
							get_dbus_data();
							hideProgress();
						}
					}
				}); 
			}

			function hook_event() {
				$(E(params.enable)).click(
					function () {
						if (E(params.enable).checked) {
							E("core_version").style.display = "";
							E("last_status").style.display = "";
							E("svr_restart").style.display = "";
							E("user_id").style.display = "";
						} else {
							E("core_version").style.display = "none";
							E("last_status").style.display = "none";
							E("svr_restart").style.display = "none";
							E("user_id").style.display = "none";
						}
					}
				);
			}

			function update_visibility() {
				if (E(params.enable).checked) {
					E("core_version").style.display = "";
					E("last_status").style.display = "";
					E("svr_restart").style.display = "";
					E("user_id").style.display = "";
				} else {
					E("core_version").style.display = "none";
					E("last_status").style.display = "none";
					E("svr_restart").style.display = "none";
					E("user_id").style.display = "none";
				}
			}

			function LoadProgress(){ //显示进度
				document.getElementsByTagName("html")[0].style.overflow = "hidden";
				document.getElementById("Loading").style.width = "100%";
				document.getElementById("Loading").style.height = "100%";
				document.getElementById("Loading").style.visibility = "visible";
				document.getElementById("loadingBlock").style.left = "50%";
				document.getElementById("loadingBlock").style.top = "30%";
				document.getElementById("loadingBlock").style.transform = "translate(-50%, -50%)";
				document.getElementById("proceeding_main_txt").innerHTML = "正在处理请稍后...";
				document.getElementById("proceeding_txt").innerHTML = "";
			}

			function hideProgress(){ //隐藏进度
				document.getElementById("proceeding_main_txt").innerHTML = "完成";
				setTimeout(function(){
					document.getElementsByTagName("html")[0].style.overflow = "";
					document.getElementById("Loading").style.width = "initial";
					document.getElementById("Loading").style.height = "initial";
					document.getElementById("Loading").style.visibility = "hidden";
					document.getElementById("loadingBlock").style = "";
					document.getElementById("proceeding_main_txt").innerHTML = "";
					document.getElementById("proceeding_txt").innerHTML = "";
				}, 1000);
			}

			function menu_hook() {
				tabtitle[tabtitle.length - 1] = new Array("", "easytier");
				tablink[tablink.length - 1] = new Array("", "Module_easytier.asp");
			}

			function reload_Soft_Center() {
				location.href = "/Module_Softcenter.asp";
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
												<div class="formfonttitle" style="float:left;">EasyTier</div>
												<div style="float:right; width:15px; height:25px;margin-top:10px">
													<img onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
												</div>
												<div class="splitLine" style="margin:30px 0 10px 5px;"></div>
												<div style="margin-left:5px;">
													<li><a target="_blank" href="https://easytier.cn" title="跳转到官网"><em><u>EasyTier</u></em></a>是一款开源的国内免费内网穿透组网方案</li>
												</div>
												<div style="margin:5px 0px 0px 0px;">
													<table class="FormTable" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3">
														<thead>
															<tr>
																<td colspan="2">服务配置</td>
															</tr>
														</thead>
														<tr id="switch_tr">
															<th>
																<label>开启服务</label>
															</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell">
																	<label for="easytier_enable">
																		<input id="easytier_enable" class="switch" type="checkbox" style="display:none;" />
																		<div class="switch_container">
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
																<div id="easytier_version" style="padding-top:5px;margin-right:30px;margin-top:-30px;float:right;"></div>
															</td>
														</tr>
														<tr id="core_version" style="display:none;">
															<th style="cursor:help;" title="EasyTier内核发行版本号">内核版本</th>
															<td>
																<span id="easytier_core"></span>
															</td>
														</tr>
														<tr id="last_status" style="display:none;">
															<th>运行状态</th>
															<td>
																<span id="easytier_status"></span>
															</td>
														</tr>
														<tr id="svr_restart" style="display:none;">
															<th style="cursor:help;" title="当设备重启或断开时允许强制启动服务">服务进程守护</th>
															<td>
																<input type="checkbox" id="easytier_watchdog" style="vertical-align:middle;" />
															</td>
														</tr>
														<tr id="user_id" style="display:none;">
															<th style="cursor:help;" title="用户名需注册后再进行关联">设置关联用户</th>
															<td>
																<input type="text" class="input_ss_table" id="easytier_id" placeholder="用户名" maxlength="16" onkeypress="javascript:event.returnValue=((event.keyCode >= 48 && event.keyCode <= 57)||(event.keyCode >= 65 && event.keyCode <= 90)||(event.keyCode >= 97 && event.keyCode <= 122))?true:false;">
																<span style="padding-top:5px;margin-left:10px;margin-right:30px;">前往Web控制台<a target="_blank" href="https://easytier.cn/web#/auth/register"><em><u>注册</u></em></a>或<a target="_blank" href="https://easytier.cn/web"><em><u>配置组网</u></em></a></span>
															</td>
														</tr>
													</table>
												</div>
												<div id="apply_gen" class="apply_gen" style="margin-top:20px;margin-bottom:10px;">
													<input id="apply_button" class="button_gen" type="button" onclick="save()" value="提 交" />
												</div>
											</td>
										</tr>
									</table>
								</div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<div id="footer"></div>
	</body>
</html>
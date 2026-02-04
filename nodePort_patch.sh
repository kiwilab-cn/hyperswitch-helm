#!/bin/bash
# hyperswitch-expose.sh
# 用法: bash hyperswitch-expose.sh
# 将 Hyperswitch 核心服务暴露为 NodePort（固定端口）

set -e
NS="hyperswitch"

echo "============================================"
echo "  Expose Hyperswitch via NodePort"
echo "============================================"

# patch 函数: 服务名 + 期望的 NodePort
patch_svc() {
  local SVC=$1
  local NP=$2
  local DESC=$3
  kubectl patch svc "$SVC" -n "$NS" --type='json' -p="[
    {\"op\":\"replace\", \"path\":\"/spec/type\",            \"value\":\"NodePort\"},
    {\"op\":\"add\",    \"path\":\"/spec/ports/0/nodePort\", \"value\":$NP}
  ]"
  echo "  ✓ $SVC → NodePort $NP  ($DESC)"
}

echo ""
echo "[1/4] Patching services..."
patch_svc "hyperswitch-server"          30080   "支付 API"
patch_svc "hyperswitch-control-center"  30090   "管理后台"
patch_svc "hyperswitch-web"             30950   "支付 SDK"
patch_svc "hyperswitch-grafana"           33000   "Grafana 监控"

echo ""
echo "[2/4] Service 状态:"
kubectl get svc -n "$NS"

echo ""
echo "[3/4] Node 信息 (看 EXTERNAL-IP 列):"
kubectl get nodes -o wide

echo ""
echo "[4/4] 访问地址 (替换 <NODE_IP> 为上面的 EXTERNAL-IP):"
echo ""
echo "  http://<NODE_IP>:30080   →  支付 API  (商户程序调用)"
echo "  http://<NODE_IP>:30090   →  管理后台  (浏览器访问)"
echo "  http://<NODE_IP>:30950   →  支付 SDK  (终端用户)"
echo "  http://<NODE_IP>:33000   →  Grafana   (运维监控)"
echo ""
echo "============================================"
echo "  ⚠ 别忘了配 EC2 Security Group，见下文"
echo "============================================"

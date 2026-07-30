<!-- Heartbeat template; comments-only content prevents scheduled heartbeat API calls. -->

# Keep this file empty (or with only comments) to skip heartbeat API calls.

# Add tasks below when you want the agent to check something periodically.

## 会话启动同步
每次心跳时，先执行 `git pull origin main` 拉取最新 workspace 内容（如果远端有更新的话）。

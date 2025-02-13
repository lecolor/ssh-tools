#!/bin/bash

# 用于存储加密地址和密码的文件
PASSWORD_FILE="$HOME/.ssh/ssh_passwords.txt"
ENCRYPTION_PASSWORD="chrdw-hdhxt-szpzc-lljxk" # 可以将这个密码存储在环境变量中以增强安全性

# 打印帮助信息
print_usage() {
    echo "用法: $0 <用户名@主机地址>"
    echo "选项:"
    echo "  -h         显示帮助信息"
    echo "  -c         清空密码文件"
    echo "  -d         删除指定目标的密码"
    exit 1
}

# 检查密码文件是否存在，如果不存在则创建
if [ ! -f "$PASSWORD_FILE" ]; then
    touch "$PASSWORD_FILE"
fi

_ssh_connect() {
    passwd="$1"
    target="$2"
    sshpass -p "$passwd" ssh -t -o StrictHostKeyChecking=no "$target"
}

# 功能：清空密码文件
clear_passwords() {
    echo "确认要清空所有密码记录吗? (y/n)"
    read -r confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
        : >"$PASSWORD_FILE"
        echo "密码文件已清空。"
    fi
}

# 功能：删除指定目标密码
delete_password() {
    echo "请输入要删除密码的目标地址 (例如: user@hostname)："
    read -r target_to_delete
    if grep -q "$target_to_delete" "$PASSWORD_FILE"; then
        sed -i '' "/$target_to_delete/d" "$PASSWORD_FILE"
        echo "$target_to_delete 的密码已删除。"
    else
        echo "目标 $target_to_delete 不存在，无法删除。"
    fi
}

# 解析命令行参数
while getopts "hcd" opt; do
    case "$opt" in
    h) print_usage ;;
    c)
        clear_passwords
        exit 0
        ;;
    d)
        delete_password
        exit 0
        ;;
    *) print_usage ;;
    esac
done

# 检查传入的参数是否为空
if [ -z "$1" ]; then
    print_usage
fi

# 获取目标主机（第一个参数）
TARGET="$1"
USER=$(echo "$TARGET" | cut -d'@' -f1)
HOST=$(echo "$TARGET" | cut -d'@' -f2)

# 检查目标地址和用户名的组合是否已保存密码
if grep -q "$TARGET" "$PASSWORD_FILE"; then
    # 提取加密的行并解密密码
    ENCRYPTED_ENTRY=$(grep "$TARGET" "$PASSWORD_FILE")
    ENCRYPTED_PASSWORD=$(echo "$ENCRYPTED_ENTRY" | cut -d' ' -f2)

    # 解密密码，使用pbkdf2派生算法
    PASSWORD=$(echo "$ENCRYPTED_PASSWORD" | openssl enc -aes-256-cbc -d -base64 -pass pass:"$ENCRYPTION_PASSWORD" -pbkdf2)

    # 执行 SSH 连接，使用解密后的密码
    echo "尝试使用保存的密码连接 $USER@$HOST..."

    # 使用 sshpass 和解密后的密码，启动 SSH 会话
    # 如果 SSH 登录失败，提示重新输入密码
    if ! _ssh_connect "$PASSWORD" "$USER@$HOST"; then
        echo "密码错误，请重新输入密码。"
        PASSWORD=""
        while [ -z "$PASSWORD" ]; do
            read -r -s -p "密码: " PASSWORD
            echo
        done

        # 加密新密码并更新文件
        ENCRYPTED_PASSWORD=$(echo -n "$PASSWORD" | openssl enc -aes-256-cbc -base64 -salt -pass pass:"$ENCRYPTION_PASSWORD" -pbkdf2)

        # 更新密码文件
        sed -i '' "s/^$TARGET .*/$TARGET $ENCRYPTED_PASSWORD/" "$PASSWORD_FILE"
        echo "密码已更新。"

        # 使用新的密码进行 SSH 登录
        _ssh_connect "$PASSWORD" "$USER@$HOST"
    fi
else
    echo "未找到保存的密码，请输入密码："

    # 请求用户输入密码
    PASSWORD=""
    while [ -z "$PASSWORD" ]; do
        read -r -s -p "密码: " PASSWORD
        echo
    done

    # 加密密码并保存
    ENCRYPTED_PASSWORD=$(echo -n "$PASSWORD" | openssl enc -aes-256-cbc -base64 -salt -pass pass:"$ENCRYPTION_PASSWORD" -pbkdf2)

    # 保存地址和加密后的密码到文件
    echo "$TARGET $ENCRYPTED_PASSWORD" >>"$PASSWORD_FILE"
    echo "密码已加密并保存。"

    # 使用 `sshpass` 进行 SSH 登录
    echo "尝试连接 $USER@$HOST..."
    # 如果登录失败，提示重新输入密码
    if ! _ssh_connect "$PASSWORD" "$USER@$HOST"; then
        echo "密码错误，请重新输入密码。"
        PASSWORD=""
        while [ -z "$PASSWORD" ]; do
            read -s -p "密码: " PASSWORD
            echo
        done

        # 加密新密码并更新文件
        ENCRYPTED_PASSWORD=$(echo -n "$PASSWORD" | openssl enc -aes-256-cbc -base64 -salt -pass pass:"$ENCRYPTION_PASSWORD" -pbkdf2)

        # 更新密码文件
        echo "$TARGET $ENCRYPTED_PASSWORD" >>"$PASSWORD_FILE"
        echo "密码已更新。"

        # 使用新的密码进行 SSH 登录
        _ssh_connect "$PASSWORD" "$USER@$HOST"
    fi
fi

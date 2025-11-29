#!/bin/bash

BIN_SDK=/app/ProxyRack
LOCK_FILE=/app/LOCK_FILE.cfg
var_proxyrack_api="https://peer.proxyrack.com/api/device/add"
var_version=$(curl -s https://app-updates.sock.sh/peerclient/go/version.txt)

if [ -z "$TOKEN" ]; then
    echo " >>> ProxyRack >>> Please set the UUID environment variable."
    sleep 1
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo " >>> ProxyRack >>> Please set the API_KEY environment variable."
    sleep 1
    exit 1
fi

if [ -z "$DEVICE_NAME" ]; then
    echo " >>> ProxyRack >>> Please set the DEVICE_NAME environment variable."
    sleep 1
    exit 1
fi

proxyrack_test() {
    if nc -z point-of-presence.sock.sh 443 >/dev/null 2>&1; then
        echo " >>> ProxyRack >>> Connection established ProxyRack is ready to use."
        sleep 1
        return 0
    else
        echo " >>> ProxyRack >>> Unable to reach ProxyRack please check your internet or try again later."
        sleep 1
        return 1
    fi
}

proxyrack_start() {
    echo " >>> ProxyRack >>> Running $BIN_SDK ."
    mkfifo -m 600 /tmp/dummy || true
    tail -f /dev/null > /tmp/dummy &
    exec $BIN_SDK --homeIp point-of-presence.sock.sh \
                  --homePort 443 \
                  --id "${TOKEN}" \
                  --version "${var_version}" \
                  --clientKey proxyrack-pop-client \
                  --clientType PoP \
                  --osType Linux \
                  --osRelease 6.15.0-0-generic \
                  --osArch x64 < /tmp/dummy
}

proxyrack_add() {
    echo " >>> ProxyRack >>> Adding device."
    while true; do
        response=$(curl -s -X POST "${var_proxyrack_api}" \
            -H "Api-Key: ${API_KEY}" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d '{"device_id":"'"${TOKEN}"'","device_name":"'"${DEVICE_NAME}"'"}')

        status=$(echo "$response" | jq -r '.status // empty')
        error=$(echo "$response" | jq -r '.error // empty')
        details=$(echo "$response" | jq -r '.details.device_id // empty')
        message=$(echo "$response" | jq -r '.message // empty')

        if [ "$status" = "success" ]; then
            echo " >>> ProxyRack >>> $message"
            touch "${LOCK_FILE}"
            return 0

        elif [ "$status" = "error" ]; then
            echo " >>> ProxyRack >>> Error: $error | Details: $details"

            if echo "$details" | grep -qi "already been taken"; then
                echo " >>> ProxyRack >>> Device ID already registered."
                touch "${LOCK_FILE}"
                return 0
            elif echo "$details" | grep -qi "Device not found"; then
                echo " >>> ProxyRack >>> Device not found yet, retrying in 6 minute..."
                sleep 360
                continue
            else
                echo " >>> ProxyRack >>> Unhandled error. Retrying in 6 minute..."
                echo "$response"
                sleep 360
                continue
            fi

        else
            echo " >>> ProxyRack >>> Unexpected response. Full body below:"
            echo "$response"
            sleep 60
        fi
    done
}

proxyrack_test
proxyrack_start &

if [ -f "${LOCK_FILE}" ]; then
    echo " >>> ProxyRack >>> ${LOCK_FILE} already exists."
else
    echo " >>> ProxyRack >>> ${LOCK_FILE} does not exist."
    proxyrack_add &
fi

tail -f /dev/null

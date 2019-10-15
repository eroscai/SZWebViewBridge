(function () {
    if (window.szBridge) {
        return
    }
    window.szBridge = function () {
        var callbacks = [],
            callbackID = 0,
            registerHandlers = [];
        document.addEventListener('SZDidReceiveNativeCallback', function (e) {
            if (e.detail) {
                var detail = e.detail;
                var id = isNaN(parseInt(detail.id)) ? -1 : parseInt(detail.id)
                if (id != -1) {
                    callbacks[id] && callbacks[id](detail.params, detail.error);
                    delete callbacks[id];
                }
            }
        }, false);
        document.addEventListener('SZDidReceiveNativeBroadcast', function (e) {
            if (e.detail) {
                var detail = e.detail;
                var name = detail.name
                if (name !== undefined && registerHandlers[name]) {
                    var namedListeners = registerHandlers[name]
                    if (namedListeners instanceof Array) {
                        var params = detail.params
                        namedListeners.forEach(function (handler) {
                            handler(params)
                        })
                    }
                }
            }
        }, false);
        return {
            'post': function (action, params, callback) {
                var id = callbackID++;
                callbacks[id] = callback;
                // For iOS
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.szBridge) {
                    window.webkit.messageHandlers.szBridge.postMessage({
                        'action': action,
                        'params': params,
                        'callback': id || 0
                    })
                } else {
                    var jsonMessage = {
                        'action': action,
                        'params': params,
                        'callback': id || 0
                    }
                    // For Android
                    if (window.szBridge && window.szBridge.didReceiveMessage) {
                        window.szBridge.didReceiveMessage(JSON.stringify(jsonMessage))
                    } else {
                        // For Apps Havn't Implement (Message Bridge)
                        var openURLString = "szBridge://postMessage?_json=" + encodeURIComponent(JSON.stringify(jsonMessage));
                        var bridgeFrame = document.createElement("iframe");
                        bridgeFrame.setAttribute("src", openURLString);
                        document.documentElement.appendChild(bridgeFrame);
                        bridgeFrame.parentNode.removeChild(bridgeFrame);
                        bridgeFrame = null;
                    }
                }
            },
            'on': function (name, callback) {
                var namedListeners = registerHandlers[name]
                if (!namedListeners) {
                    registerHandlers[name] = namedListeners = []
                }
                namedListeners.push(callback);
                return function () {
                    namedListeners[indexOf(namedListeners, callback)] = null
                }
            },
            'off': function (name) {
                delete registerHandlers[name];
            }
        }
    }()
}());
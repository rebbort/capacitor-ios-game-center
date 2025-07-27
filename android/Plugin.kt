package com.example.gamecenter

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "GameCenter")
class GameCenterPlugin : Plugin() {
    @PluginMethod
    fun authenticateSilent(call: PluginCall) {
        call.reject("iOS only")
    }
}


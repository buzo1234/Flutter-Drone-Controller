#include <Arduino.h>
#include <ESP8266WiFi.h> //import for wifi functionality
#include <WebSocketsServer.h> //import for websocket

#define ledpin D2 //defining the OUTPUT pin for LED

const char *ssid =  "PYI Tech";   //Wifi SSID (Name)   
const char *pass =  "karanbuzo"; //wifi password

WebSocketsServer webSocket = WebSocketsServer(81); //websocket init with port 81

String getValue(String data, char separator, int index)
            {
              int found = 0;
              int strIndex[] = {0, -1};
              int maxIndex = data.length()-1;

              for(int i=0; i<=maxIndex && found<=index; i++){
                if(data.charAt(i)==separator || i==maxIndex){
                    found++;
                    strIndex[0] = strIndex[1]+1;
                    strIndex[1] = (i == maxIndex) ? i+1 : i;
                }
              }
               return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
            }

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
//webscket event method
    String cmd = "";
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.println("Websocket is disconnected");
            //case when Websocket is disconnected
            break;
        case WStype_CONNECTED:{
            //wcase when websocket is connected
            Serial.println("Websocket is connected");
            Serial.println(webSocket.remoteIP(num).toString());
            webSocket.sendTXT(num, "connected");}
            break;
        case WStype_TEXT:
        {
            cmd = "";
            for(int i = 0; i < length; i++) {
                cmd = cmd + (char) payload[i]; 
            } //merging payload to single string
            
            

              String roll = getValue(cmd,':', 0);
              String pitch = getValue(cmd,':', 1);
              String throttle = getValue(cmd,':', 2);
              String yaw = getValue(cmd,':', 3);

             
            Serial.println("Roll " + roll + "Pitch" + pitch + "Throttle" + throttle + "Yaw" + yaw);
            String newMsg = cmd+":success";

            webSocket.sendTXT(num, newMsg);
             //send response to mobile, if command is "poweron" then response will be "poweron:success"
             //this response can be used to track down the success of command in mobile app.
            break;}
        case WStype_FRAGMENT_TEXT_START:
        {break;}
            
        case WStype_FRAGMENT_BIN_START:
        {break;}
            
        case WStype_BIN:
        {hexdump(payload, length);
            break;}
            
        default:
        {break;}
            
    }
}

void setup() {
    //set ledpin (D2) as OUTPUT pin
   Serial.begin(9600); //serial start

   Serial.println("Connecting to wifi");
   
   IPAddress apIP(192, 168, 0, 1);   //Static IP for wifi gateway
   WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); //set Static IP gateway on NodeMCU
   WiFi.softAP(ssid, pass); //turn on WIFI

   webSocket.begin(); //websocket Begin
   webSocket.onEvent(webSocketEvent); //set Event for websocket
   Serial.println("Websocket is started");
}

void loop() {
   webSocket.loop(); //keep this line on loop method
}
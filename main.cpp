#include "mbed.h"
#include "LCD_DISCO_F746NG.h" //include LCD display library
#include "TS_DISCO_F746NG.h" // include LCD Touch Screen library

LCD_DISCO_F746NG lcd; //refer to LCD screen as lcd
TS_DISCO_F746NG ts; // refer to Touch Screen as ts
DigitalOut led1(LED1);

int main(){
            
            uint8_t status;
            TS_StateTypeDef TS_State;
            
            status = ts.Init(lcd.GetXSize(), lcd.GetYSize()); 
            if (status != TS_OK) { //checks if touch screen functions normally
                lcd.Clear(LCD_COLOR_RED);  //clears the screen and fills it with red
                lcd.SetBackColor(LCD_COLOR_RED);
                lcd.SetTextColor(LCD_COLOR_WHITE);
                lcd.DisplayStringAt(0, LINE(5), (uint8_t *)"TOUCHSCREEN INIT FAIL", CENTER_MODE);
                } 
            else { // delete this part later on
                lcd.Clear(LCD_COLOR_BLUE);
                lcd.SetBackColor(LCD_COLOR_BLUE);
                lcd.SetTextColor(LCD_COLOR_WHITE);
                lcd.DisplayStringAt(0, LINE(5), (uint8_t *)"TOUCHSCREEN INIT OK", CENTER_MODE);
                }
            wait(3);
            //display "start", and wait for user touching the screen before running rest of code    
            lcd.Clear(LCD_COLOR_BLUE);
            lcd.SetBackColor(LCD_COLOR_WHITE);
            lcd.SetTextColor(LCD_COLOR_BLACK);                        
            lcd.DisplayStringAt(0, LINE(1), (uint8_t *)"Welcome", CENTER_MODE);
           // lcd.DrawCircle(237, 155, 70); //first argument is X position, 2nd is Y position, 3rd is radius of circle
            lcd.FillCircle(237, 155, 70);
            lcd.SetBackColor(LCD_COLOR_BLACK);            
            lcd.SetTextColor(LCD_COLOR_WHITE);                        
            lcd.DisplayStringAt(0, LINE(6), (uint8_t *)"Start", CENTER_MODE); // first argument is X pos, second is Y pos
            ts.GetState(&TS_State);
            while(TS_State.touchDetected == false){ //start the code once we've pressedthe screen
                ts.GetState(&TS_State);
                }
            lcd.Clear(LCD_COLOR_BLUE); 
            lcd.SetTextColor(LCD_COLOR_BLACK);                        
            lcd.FillRect(138, 60, 200, 150);
            lcd.SetTextColor(LCD_COLOR_WHITE);                        
            lcd.DisplayStringAt(0, LINE(3), (uint8_t *)"Driver", CENTER_MODE);
            lcd.DisplayStringAt(0, LINE(5), (uint8_t *)"Alertness", CENTER_MODE);
            lcd.DisplayStringAt(0, LINE(7), (uint8_t *)"System", CENTER_MODE);
                       

}
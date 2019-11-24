# ardunioserialin

A new Flutter project.

## Getting Started

an app that can be used as oscilloscope that from usb through arduino in the range of 10 t0 -10

upload this code in ardunio.

static int temp=0;

void setup()
{
    Serial.begin(9600);
    pinMode(13, OUTPUT);
}

void loop()
{
    digitalWrite(13,HIGH);
    if(temp <100 && temp > 50){
    Serial.println(6.0);
    

    }else if (temp==100){
        temp=0;
    }else{
        Serial.println(3.0);
    }
    temp++;
}



connect arduino to mobile usb port through otg.

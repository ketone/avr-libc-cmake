#include <avr/io.h>
#include <util/delay.h>



int main(void) {
    // Set Data Direction Register: Set Pin 5 of Port B (Arduino Uno Built-in LED) as output
    DDRB |= (1 << DDB5);

    while(1) {
        PORTB |= (1 << PORTB5);  // Turn LED on
        _delay_ms(100);          // Wait 500ms
        PORTB &= ~(1 << PORTB5); // Turn LED off
        _delay_ms(100);          // Wait 500ms
    }
    return 0;
}


// Fix the undefined reference to _exit by creating a hardware loop stub
 void _exit(int status) __attribute__((noreturn));
 void _exit(int status) {
     (void)status; // Unused parameter
     while(1) {
         // Infinite low-power or safety loop to stop execution safely
         __asm__ __volatile__("cli \n\t wdr \n\t sleep"); 
     }
 }
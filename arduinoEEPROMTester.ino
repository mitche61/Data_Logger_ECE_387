#include <eeprom.h>


// Change this to define how many bytes to write.
uint16_t BYTES_TO_WRITE = 800;
int BYTES_TO_WRITE_INT = 800;
byte DUMMY_DATA = 0x11;
int RANGE_TOLERANCE = 8; // how many adjacent samples will be traversed to find "match; 190 / 12 = 15.833Hz min frequency for guessing.
                          // if attempting to guess frequency lower than this then range tolerance will have to be turned up.
int VAL_TOLERANCE = 10; // in quantization levels (19.53 mV); for lower amplitude signals turn down this tolerance

EEPROM myEEPROM(0x50); // I2C address.

void setup()
{
  Serial.begin(9600);

  // Checking connection
  if (myEEPROM.begin()) {
    Serial.println("EEPROM memory detected.");
  }
  else {
    Serial.println("EEPROM memory not detected!");
    return;
  }
  Serial.println("Reading EEPROM memory...");

  // Eric's array
  byte vals[BYTES_TO_WRITE_INT];
  
  // First read of current data in memory.
  int count = 0;
  for (uint16_t address = 0x0000; address < BYTES_TO_WRITE; address++) {
//    Serial.print("\tAddress: ");
//    Serial.print(address, DEC);
//    Serial.print(": ");
//    Serial.println(myEEPROM.read_byte(address), HEX);
      vals[address] = myEEPROM.read_byte(address);

//      if (i % 200 == 0) {
//          Serial.print("Reading value ");
//          Serial.print(i);
//          Serial.print("/");
//          Serial.println(BYTES_TO_WRITE_INT);
//      }
//      Serial.println(vals[address]);
      count++;
  }

  // ERIC's STUFF vvv
  Serial.println("Beginning calculations...");
  
  int freqGuesses[BYTES_TO_WRITE_INT - RANGE_TOLERANCE];
  for (int i = 0; i < BYTES_TO_WRITE_INT - RANGE_TOLERANCE; i++) {
      float percent = ((float) i) / ((float) BYTES_TO_WRITE - RANGE_TOLERANCE);
      if (percent > .24 && percent < .26) {
          Serial.print(percent * 100);
          Serial.println("% done...");
      }
      else if (percent > .49 && percent < .51) {
          Serial.print(percent * 100);
          Serial.println("% done...");
      }
      else if (percent > .74 && percent < .76) {
          Serial.print(percent * 100);
          Serial.println("% done...");
      }
      for (int j = i + 1; j <= i + RANGE_TOLERANCE; j++) {
          if (abs(vals[i] - vals[j]) <= VAL_TOLERANCE) {
              Serial.print("i= j= ");
              Serial.print(i);
              Serial.print(" ");
              Serial.println(j);
              freqGuesses[i] = abs(j - i);
              break; 
          }
          else {
              freqGuesses[i] = 0;
          }
      }
  }

  for (int i = 0; i < BYTES_TO_WRITE_INT - RANGE_TOLERANCE; i++) {
      Serial.print("Freq Guesses[");
      Serial.print(i);
      Serial.print("]: ");
      Serial.println(freqGuesses[i]);
  }

  Serial.println("Calculations completed!");

  int sum = 0;
  int valsCounted = 0;
  for (int i = 0; i < BYTES_TO_WRITE_INT - RANGE_TOLERANCE; i++) {
      if (freqGuesses[i] != 0) {
          sum += freqGuesses[i];
          valsCounted++;
      }
  }
  float avg = (((float) sum) / ((float) valsCounted));
  float freq = 190 / avg;
  Serial.print("Frequency guess: ");
  Serial.print(freq);
  Serial.println("Hz");


  // Eric's Stuff ^^^

  
  /*
  Serial.println("\nWriting EEPROM memory...\n");
  
  // First write of new data into the memory.
  for (uint16_t address = 0x0000; address < BYTES_TO_WRITE; address++) {
    myEEPROM.write_byte(address, (byte) DUMMY_DATA);
  }
  
  Serial.println("Reading EEPROM memory...");
  
  // Second read of new data in memory.
  for (uint16_t address = 0x0000; address < BYTES_TO_WRITE; address++) {
    Serial.print("\tAddress: ");
    Serial.print(address, HEX);
    Serial.print(":");
    Serial.println(myEEPROM.read_byte(address), HEX);
  }
  */
  /*
  Serial.println("\nErasing EEPROM memory...\n");
  
  // Erasing data written into the memory.
  for (uint16_t address = 0x0000; address < BYTES_TO_WRITE; address++) {
    myEEPROM.erase_byte(address);
  }*/
  /*
  Serial.println("Reading EEPROM memory...");
  
  // Third read of free locations in memory.
  for (uint16_t address = 0x0000; address <= BYTES_TO_WRITE; address++) {
    Serial.print("\tAddress: ");
    Serial.print(address, HEX);
    Serial.print(":");
    Serial.println(myEEPROM.read_byte(address), HEX);
  }
  */
  //Serial.println("\nDone!");
}

void loop()
{

}

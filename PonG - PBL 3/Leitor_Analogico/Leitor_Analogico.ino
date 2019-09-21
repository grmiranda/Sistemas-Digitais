const int pinoPOT1 = A1; //PINO ANALÓGICO UTILIZADO PELO POTENCIÔMETRO 1
const int pinoPOT2 = A0; //PINO ANALÓGICO UTILIZADO PELO POTENCIÔMETRO 2

int posP1 = 0;
int posP2 = 0;
boolean control = true;

void setup(){
   Serial.begin(115200);
   pinMode(pinoPOT1, INPUT); //DEFINE O PINO COMO ENTRADA
   pinMode(pinoPOT2, INPUT); //DEFINE O PINO COMO ENTRADA
}

void loop(){
    posP1 = map(analogRead(pinoPOT1), 0, 1023, 0, 10); //EXECUTA A FUNÇÃO "map" DE ACORDO COM OS PARÂMETROS PASSADOS
    posP2 = map(analogRead(pinoPOT2), 0, 1023, 0, 9); //EXECUTA A FUNÇÃO "map" DE ACORDO COM OS PARÂMETROS PASSADOS

    if(control){
      Serial.print("A");
      Serial.print(posP1);
      control = false;
    }else{
      Serial.print("B");
      Serial.print(posP2);
      control = true;
    }
}

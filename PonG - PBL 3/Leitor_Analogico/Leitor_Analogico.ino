const int pinoPOT1 = A1; //PINO ANALÓGICO UTILIZADO PELO POTENCIÔMETRO 1
const int pinoPOT2 = A0; //PINO ANALÓGICO UTILIZADO PELO POTENCIÔMETRO 2

int posP1 = 0;
int posP2 = 0;
String retorno;

void setup(){
   Serial.begin(9600);
   pinMode(pinoPOT1, INPUT); //DEFINE O PINO COMO ENTRADA
   pinMode(pinoPOT2, INPUT); //DEFINE O PINO COMO ENTRADA
}

void loop(){
  delay(100);
    posP1 = map(analogRead(pinoPOT1), 0, 1023, 0, 255); //EXECUTA A FUNÇÃO "map" DE ACORDO COM OS PARÂMETROS PASSADOS
    posP2 = map(analogRead(pinoPOT2), 0, 1023, 0, 255); //EXECUTA A FUNÇÃO "map" DE ACORDO COM OS PARÂMETROS PASSADOS
    Serial.println(Serial.read());
    if(retorno.equals("1")){
      Serial.print("A");
      Serial.print(posP1);
      Serial.print("B");
      Serial.print(posP2);
      Serial.println(" ");
      retorno = "0";
    }
}

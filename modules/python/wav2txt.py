import azure.cognitiveservices.speech as speechsdk
import time
import sys
import os.path
import errno

if __name__ == "__main__":
    args = sys.argv

    speech_key = "77a786d869364dfeb521c65d2db1b770"
    region=service_region = "brazilsouth"
    language = "pt-BR"
    profanity = speechsdk.ProfanityOption.Raw

def from_file(audiofile):
    """Transcreve um trecho de audio em texto a partir de um arquivo, ideal para arquivos pequenos"""

    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    speech_config.speech_recognition_language=language
    speech_config.set_profanity(profanity)  
    audio_input = speechsdk.AudioConfig(filename=audiofile)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_input)

    result = speech_recognizer.recognize_once_async().get()
    return result.text

def speech_recognize_continuous_from_file(audiofile):
    """Transcreve um trecho de audio de forma contínua a partir de um arquivo"""

    # Parâmetros de configuração
    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    speech_config.speech_recognition_language=language  
    speech_config.set_profanity(profanity)
    audio_config = speechsdk.audio.AudioConfig(filename=audiofile)
    speech_recognizer = speechsdk.SpeechRecognizer(speech_config=speech_config, audio_config=audio_config)

    # Definição das funções que são chamadas durante o disparo dos eventos
    def stop(evt):
        """Evento que encerra o reconhecimento de voz"""
        speech_recognizer.stop_continuous_recognition()
        nonlocal done
        done = True

    def handle_final_result(evt):
        nonlocal result
        result.append(evt.result.text)

    # Chamada dos eventos
    speech_recognizer.recognized.connect(handle_final_result)
    speech_recognizer.session_stopped.connect(stop)
    speech_recognizer.canceled.connect(stop)

    # Início do reconhecimento    
    result = []
    done = False

    speech_recognizer.start_continuous_recognition()
    while not done:
        time.sleep(0.5)

    # Converte lista de frases em string única
    all_results = ' '.join([str(item) for item in result])

    return all_results

inputpath = args[1]
outputpath = args[2]

if not os.path.exists(os.path.dirname(outputpath)):
    try:
        os.makedirs(os.path.dirname(outputpath))
    except OSError as exc: # Guard against race condition
        if exc.errno != errno.EEXIST:
            raise

with open(outputpath, "w") as f:
    f.write(speech_recognize_continuous_from_file(inputpath))
f.close()
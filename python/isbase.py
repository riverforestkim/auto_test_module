import base64
import binascii

def isBase64(string):

    bStr = bytes(string, 'utf-8')
    
    try:
        tempStr = base64.decodebytes(bStr)
        return "True"
    except binascii.Error:
        return "False"

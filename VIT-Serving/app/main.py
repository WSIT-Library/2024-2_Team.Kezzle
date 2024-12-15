import requests
import torch
from PIL import Image
from torchvision.models import ViT_B_16_Weights
from io import BytesIO

DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'

weights = ViT_B_16_Weights.DEFAULT
transform = weights.transforms()
model = torch.load('model.pt', map_location=torch.device(DEVICE))

def get_vector(url):
    response = requests.get(url)
    img = Image.open(BytesIO(response.content))
    img = transform(img)
    
    with torch.inference_mode():
        vectors = model(img.unsqueeze(0).to(DEVICE))
    return vectors.squeeze(0)

def lambda_handler(event, context):
    try:
        object_url = event['url']

        return {
            "model": "vit",
            "key": event['key'],
            "vector": get_vector(object_url).tolist()
        }
    except Exception as e:
        print(e)
        raise e
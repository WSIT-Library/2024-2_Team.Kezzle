import torch
from torchvision.models import vit_b_16, ViT_B_16_Weights

DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'

weights = ViT_B_16_Weights.DEFAULT
transform = weights.transforms()
model = vit_b_16(weights=weights).to(DEVICE)
torch.save(model, 'model.pt')
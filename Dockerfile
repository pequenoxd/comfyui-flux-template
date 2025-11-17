# ------------------------------------------------------------------
# 1. BASE: Imagem Pytorch 2.3 estável (Recomendado)
# ------------------------------------------------------------------
FROM runpod/pytorch:2.3.0-py3.10-cuda12.1.1

# Define o diretório de trabalho padrão
WORKDIR /workspace

# ------------------------------------------------------------------
# 2. Instala dependências do sistema
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    wget \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 3. Clona o ComfyUI e cria TODAS as pastas (do seu script bash)
# ------------------------------------------------------------------
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI && \
    mkdir -p /workspace/ComfyUI/models/checkpoints \
             /workspace/ComfyUI/models/loras \
             /workspace/ComfyUI/models/upscale_models \
             /workspace/ComfyUI/models/gfpgan \
             /workspace/ComfyUI/models/pulid \
             /workspace/ComfyUI/models/flux

WORKDIR /workspace/ComfyUI

# ------------------------------------------------------------------
# 4. Instala os Nós Customizados (Exatos do seu script bash)
# ------------------------------------------------------------------
RUN cd custom_nodes && \
    git clone https://github.com/comfyanonymous/ComfyUI-Flux.git && \
    git clone https://github.com/huchenlei/ComfyUI-Pulid.git && \
    git clone https://github.com/ACGPN/ComfyUI-Image-Analysis.git && \
    git clone https://github.com/ltdrdata/ComfyUI-ADetailer.git && \
    git clone https://github.com/0xbitches/ComfyUI-GFPGAN.git && \
    git clone https://github.com/ChangZzZzzZ/ComfyUI-PhotoFusion.git && \
    cd ..

# ------------------------------------------------------------------
# 5. Instala TODAS as dependências Python (Exatas do seu script bash)
# ------------------------------------------------------------------
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -r custom_nodes/ComfyUI-Flux/requirements.txt && \
    pip install -r custom_nodes/ComfyUI-Pulid/requirements.txt && \
    pip install -r custom_nodes/ComfyUI-ADetailer/requirements.txt && \
    pip install insightface==0.7.3 onnxruntime-gpu opencv-python-headless imageio imageio-ffmpeg

# ------------------------------------------------------------------
# 6. Baixa TODOS os Modelos (Exatos do seu script bash)
# ------------------------------------------------------------------
RUN wget -O models/flux/flux-1.1-dev.safetensors \
      https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1.1-dev.safetensors && \
    \
    wget -O models/flux/flux-1.1-dev-refiner.safetensors \
      https://huggingface.co/black-forest-labs/FLUX.1-dev-refiner/resolve/main/flux1.1-dev-refiner.safetensors && \
    \
    wget -O models/flux/flux_realism.safetensors \
      https://huggingface.co/Kijai/flux-realism-lora/resolve/main/flux_realism.safetensors && \
    \
    wget -O models/pulid/pulid_flux.safetensors \
      https://huggingface.co/huchenlei/PuLID-Flux/resolve/main/pulid_flux.safetensors && \
    \
    wget -O models/pulid/eva_clip_flux.safetensors \
      https://huggingface.co/huchenlei/PuLID-Flux/resolve/main/eva_clip_flux.safetensors && \
    \
    wget -O models/upscale_models/4x-UltraSharp.pth \
      https://huggingface.co/ClaritySD/4x-UltraSharp/resolve/main/4x-UltraSharp.pth && \
    \
    wget -O models/gfpgan/GFPGANv1.4.pth \
      https://github.com/TencentARC/GFPGAN/releases/download/v1.4/GFPGANv1.4.pth

# ------------------------------------------------------------------
# 7. Porta e Comando de Inicialização
# ------------------------------------------------------------------
EXPOSE 8188
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

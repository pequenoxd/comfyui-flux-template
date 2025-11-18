# ------------------------------------------------------------------
# 1. BASE: Imagem Pytorch 2.2 estável (Sabemos que esta funciona)
# ------------------------------------------------------------------
FROM runpod/pytorch:2.2.0-py3.10-cuda12.1.1-devel-ubuntu22.04

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
# 3. Clona o ComfyUI e cria TODAS as pastas
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
# 4. Instala os Nós Customizados (APENAS CÓDIGO)
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
# 5. Instala TODAS as dependências Python
# ------------------------------------------------------------------
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install -r custom_nodes/ComfyUI-Flux/requirements.txt && \
    pip install -r custom_nodes/ComfyUI-Pulid/requirements.txt && \
    pip install -r custom_nodes/ComfyUI-ADetailer/requirements.txt && \
    pip install insightface==0.7.3 onnxruntime-gpu opencv-python-headless imageio imageio-ffmpeg

# ------------------------------------------------------------------
# 6. (REMOVIDO) Nenhum modelo (WGETs) é baixado aqui
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# 7. Porta e Comando de Inicialização
# ------------------------------------------------------------------
EXPOSE 8188
# Este comando será substituído pelo script do RunPod
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

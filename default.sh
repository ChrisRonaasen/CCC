#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(
    #"package-1"
    #"package-2"
)

NODES=(
    #"https://github.com/ltdrdata/ComfyUI-Manager"
    #"https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/MoonGoblinDev/Civicomfy"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/Comfy-Org/ComfyUI-Manager"
    "https://github.com/yuvraj108c/ComfyUI-Video-Depth-Anything"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/kijai/ComfyUI-segment-anything-2"
    "https://github.com/ai-shizuka/ComfyUI-tbox"
    "https://github.com/Azornes/Comfyui-Resolution-Master"
    "https://github.com/melMass/comfy_mtb"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
    "https://github.com/1038lab/ComfyUI-RMBG"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/TinyTerra/ComfyUI_tinyterraNodes"
    "https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes"
    "https://github.com/jags111/efficiency-nodes-comfyui"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/djbielejeski/a-person-mask-generator"
    "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
    "https://github.com/calcuis/gguf"
    "https://github.com/pollockjj/ComfyUI-MultiGPU"
    "https://github.com/1038lab/ComfyUI-QwenVL"
    "https://github.com/kijai/ComfyUI-SCAIL-Pose"
    "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/Lightricks/ComfyUI-LTXVideo"
)

WORKFLOWS=(

)

CHECKPOINT_MODELS=(
#    ""
)

UNET_MODELS=(
)

LORA_MODELS=(
)

VAE_MODELS=(
)

ESRGAN_MODELS=(
)

CONTROLNET_MODELS=(
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    rm -rf /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/
    rm -rf /workspace/ComfyUI/custom_nodes/Civicomfy/
    rm -rf /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes/
    provisioning_get_nodes
    provisioning_get_pip_packages
    cd /workspace/ComfyUI
    git config --global --add safe.directory /workspace/ComfyUI
    git checkout master
    git pull
    pip install -U pip setuptools wheel pip-tools build git huggingface-hub
    pip install -U -r /workspace/ComfyUI/requirements.txt torch==2.8 torchvision torchaudio numpy==1.26.4
    pip install -r /workspace/ComfyUI/manager_requirements.txt torch==2.8 torchvision torchaudio numpy==1.26.4
    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/unet" \
        "${UNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/lora" \
        "${LORA_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/esrgan" \
        "${ESRGAN_MODELS[@]}"
    rm -rf /workspace/ComfyUI/models/checkpoints/*.safetensors
    pip install flash-attn --no-build-isolation
    pip install sageattention --no-build-isolation
    pip install -r /workspace/ComfyUI/requirements.txt torch==2.8 torchvision torchaudio numpy==1.26.4
    pip install -r /workspace/ComfyUI/manager_requirements.txt torch==2.8 torchvision torchaudio numpy==1.26.4
    pip cache purge
    rm -rf /workspace/ComfyUI/user/default/comfy.settings.json
    rm -rf /workspace/ComfyUI/comfy_extras/nodes_qwen.py
    cd /workspace/ComfyUI
    hf auth login --token "$HF_TOKEN"
    hf download LiVeen/MISC --local-dir .
    rm -rf .cache/
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
            sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
            pip install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}custom_nodes/${dir}"
        requirements="${path}/requirements.txt torch==2.8 torchvision torchaudio numpy==1.26.4"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                   pip install --no-cache-dir -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                pip install --no-cache-dir -r "${requirements}"
            fi
        fi
    done
}

function provisioning_get_files() {
    if [[ -z $2 ]]; then return 1; fi
    
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")

    # Check if the token is valid
    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    if [[ -n $HF_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif 
        [[ -n $CIVITAI_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi
    if [[ -n $auth_token ]];then
        wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    else
        wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
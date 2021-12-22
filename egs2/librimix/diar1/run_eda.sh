#!/usr/bin/env bash

# Copyright 2021 Yushi Ueda
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)
#
# Set bash to 'debug' mode, it will exit on :
# -e 'error', -u 'undefined variable', -o ... 'error in pipeline', -x 'print commands',

set -e
set -u
set -o pipefail

train_set=train
valid_set=dev
test_sets=test

train_config1=conf/train_diar_eda_5.yaml
train_config2=conf/train_diar_eda_adapt.yaml
decode_config=conf/decode_diar.yaml

pretrain_stage=false
adapt_stage=true

if [[ ${pretrain_stage} == "true" ]]; then
./diar.sh \
    --collar 0.0 \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --ngpu 1 \
    --diar_config "${train_config1}" \
    --inference_config "${decode_config}" \
    --inference_nj 5 \
    --local_data_opts "--num_spk 2" \
    --stop_stage 5 \
    "$@"
fi

if [[ ${adapt_stage} == "true" ]]; then
./diar.sh \
    --collar 0.0 \
    --train_set "${train_set}" \
    --valid_set "${valid_set}" \
    --test_sets "${test_sets}" \
    --ngpu 1 \
    --diar_config "${train_config2}" \
    --inference_config "${decode_config}" \
    --inference_nj 5 \
    --local_data_opts "--stage 2" \
    --diar_args "--init_param exp/diar_train_diar_eda_5_raw_max_epoch250/valid.acc.ave_10best.pth" \
    --diar_tag "train_diar_eda_adapt_raw" \
    --num_spk "3"\
    "$@"
fi

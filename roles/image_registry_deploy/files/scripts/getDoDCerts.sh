#!/bin/bash

WORKING_DIR="$(git rev-parse --show-toplevel)/kubernetes/roles/image-registry-deploy/files/certs/temp"
OUTPUT_DIR="$(git rev-parse --show-toplevel)/kubernetes/roles/image-registry-deploy/files/certs/$1/trustca"

getDoDCAs() {
    cyber_mil_bundle_name=unclass-certificates_pkcs7_DoD.zip
    output_dir="$OUTPUT_DIR"
    subject_cn="unknown"
    output_file=""
    inside_cert=0
    rm -rf $WORKING_DIR/*
    cd $WORKING_DIR

    curl -k -O "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/$cyber_mil_bundle_name"
    unzip "$cyber_mil_bundle_name"

    dod_certs_name=$(echo Certificates_PKCS7_*_DoD)
    dod_certs_der=$(find "$dod_certs_name"/ -name "*DoD.der.p7b")

    input_pem="$dod_certs_name/$dod_certs_name.pem"

    touch $input_pem

    openssl pkcs7 -inform DER -print_certs -in "$dod_certs_der" -out "$input_pem"

    while IFS= read -r line; do
        if [[ "$line" == subject=* ]]; then
            cn=$(echo "$line" | sed -n 's/.*CN *= *\([^,]*\).*/\1/p' | tr ' /' '__')
            subject_cn="${cn:-unknown}"
        elif [[ "$line" == "-----BEGIN CERTIFICATE-----" ]]; then
            if [[ "$subject_cn" == "unknown" ]]; then
                counter=1
                output_file="${output_dir}/unknown.crt"
                while [[ -e "$output_file" ]]; do
                    output_file="${output_dir}/unknown_${counter}.crt"
                    ((counter++))
                done
            else
                output_file="${output_dir}/${subject_cn}.crt"
                if [[ -e "$output_file" ]]; then
                    echo "Warning: Duplicate CN '$subject_cn' detected. Skipping to prevent overwrite."
                    output_file=""
                    inside_cert=0
                    continue  # Skip writing this cert to prevent overwrite.
                fi
            fi
            echo "$line" > "$output_file"
            inside_cert=1
        elif [[ "$line" == "-----END CERTIFICATE-----" ]]; then
            if [[ "$inside_cert" -eq 1 ]]; then
                echo "$line" >> "$output_file"
                inside_cert=0
            fi
        elif [[ "$inside_cert" -eq 1 ]]; then
            echo "$line" >> "$output_file"
        fi
    done < "$input_pem"

    echo "CAs extracted to '$output_dir'"

    # Removing EMAIL and DERILITY CAs not need in our environment
    rm -f "$output_dir"/DOD_DERILITY_CA-*
    rm -f "$output_dir"/DOD_EMAIL_CA-*
}

mkdir -p $WORKING_DIR
mkdir -p $OUTPUT_DIR
getDoDCAs
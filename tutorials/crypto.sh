#!/bin/bash

# it is recommended to protect passphrase file with file permissions

declare -r RED=`tput setaf 1`
declare -r GREEN=`tput setaf 2`
declare -r RESET=`tput sgr0`
declare -r BOLD=`tput bold`
declare -r MAGENTA=`tput setaf 5`

check_file_exist () {
    
    local file=$1
    if [ ! -f $file ]; then
        echo -e "no such file or directory..."
        return
    fi
    
}

rename_output_file_enc () {
    
    local input_file=$1
    check_file_exist $input_file
    local file_name=$(basename $input_file)
    local ext="{$file_name##*.}"
    local output_file_name="${file_name}.enc"
    
    echo "$output_file_name"
}

rename_output_file_dec () {
    
    local input_file=$1
    check_file_exist $input_file
    local file_name=$(basename $input_file)
    local ext="{$file_name##*.}"
    local output_file_name="${file_name}.dec"
    
    echo "$output_file_name"
}

generate_random_secret_key () {
    
    local output_file=$1
    openssl rand -rand /dev/urandom 128 > "$output_file.key"
    echo -e "${RESET}Secret key generated with name ${BOLD}${RED}$output_file.key"
    
    return
}

generate_rsa_key_pair () {
    
    local pem_file=$1
    local passphrase_file=$2
    check_file_exist $passphrase_file
    
    openssl genpkey -aes-256-cbc -pass file:$passphrase_file -algorithm RSA -out "$pem_file.pem" -pkeyopt rsa_keygen_bits:4096
    echo -e "${RESET}Certificate generated with name ${BOLD}${RED}$pem_file.pem..."
    
    return
}

extract_public_key () {
    
    local pem_file=$1
    local passphrase_file=$2
    check_file_exist $passphrase_file
    pub_name="$pem_file.pub"
    
    openssl rsa -in $pem_file -passin file:$passphrase_file -pubout -out $pub_name
    echo -e "${RESET}Public key file extracted with name ${BOLD}${RED}$pub_name..."
    
    return
}

sym_encrypt_file () {
    
    local secret_key_file=$1
    check_file_exist $secret_key_file
    local file=$2
    check_file_exist $file
    local output_file_name=$(rename_output_file_enc $file)
    
    echo -e "${RESET}Encrypting ${BOLD}${RED}$file..."
    openssl enc -aes-256-ctr -kfile $secret_key_file -in $file -out $output_file_name
    echo -e "${RESET}Output file name => ${BOLD}${RED}$output_file_name"
    
    return
}

sym_decrypt_file () {
    
    local secret_key_file=$1
    check_file_exist $secret_key_file
    local file=$2
    check_file_exist $file
    local output_file_name=$(rename_output_file_dec $file)
    
    echo -e "${RESET}Decrypting ${BOLD}${RED}$file..."
    openssl enc -d -aes-256-ctr -kfile $secret_key_file -in $file -out $output_file_name
    echo -e "${RESET}Output file name => ${BOLD}${RED}$output_file_name"
    
    return
}

asym_encrypt_file () {
    
    local secret_key_file=$1
    check_file_exist $secret_key_file
    local public_key=$2
    check_file_exist $public_key
    local encrypted_key_name=$(rename_output_file_enc $secret_key_file)
    
    openssl rsautl -encrypt -inkey $public_key -pubin -in $secret_key_file -out $encrypted_key_name
    echo -e "${RESET}Encrypting ${RED}${BOLD}$secret_key_file..."
    echo -e "${RESET}Output file name => ${BOLD}${RED}$encrypted_key_name"
    
    return
}

asym_decrypt_file () {
    
    local pem_file=$1
    check_file_exist $pem_file
    local passphrase_file=$2
    check_file_exist $passphrase_file
    local enc_secret_key_file=$3
    check_file_exist $enc_secret_key_file
    local dec_secret_key_file=$(rename_output_file_dec $enc_secret_key_file)
    
    echo -e "${RESET}${BOLD}${RED}Decrypting $enc_secret_key_file..."
    openssl rsautl -decrypt -inkey $pem_file -passin file:$passphrase_file -in $enc_secret_key_file -out $dec_secret_key_file
    echo -e "${RESET}${BOLD}${RED}Output file name => $dec_secret_key_file"
}

option1="${RESET}Generate 128-bit random secret key"
option2="${RESET}Generate RSA public and private key pair"
option3="${RESET}Encrypt choosen file with secret key"
option4="${RESET}Encrypt secret key to be shared with friend's generated public key"
option5="${RESET}Decrypt encrypted secret key with friend's generated private key"
option6="${RESET}Decrypt encrypted file with secret key"
option7="${RESET}Quit"

menu () {
    
    PS3="${RESET}${BOLD}Please enter your choice (Press enter to display menu): ${RESET}"
    options=(
        "$option1"
        "$option2"
        "$option3"
        "$option4"
        "$option5"
        "$option6"
        "$option7"
    )
    echo "${RESET}"
    select opt in "${options[@]}"
    do
        case $opt in
            "$option1")
                read -p "${RESET}${GREEN}Enter output file name for 128-bit random secret key: " secret_key_file
                generate_random_secret_key $secret_key_file
            ;;
            "$option2")
                read -p "${RESET}${GREEN}Enter output file name for RSA pem file: " pem_file
                read -p "${RESET}${GREEN}Enter passphrase file name to be used for generation of key pair: " passphrase_file
                generate_rsa_key_pair $pem_file $passphrase_file
            ;;
            "$option3")
                read -p "${RESET}${GREEN}Enter file name to be encrypted: " file
                read -p "${RESET}${GREEN}Enter symmetric key file to encrypt specified file: " secret_key
                sym_encrypt_file $secret_key $file
            ;;
            "$option4")
                read -p "${RESET}${GREEN}Enter pem file name to extract friend's public key: " pem_file
                read -p "${RESET}${GREEN}Enter passphrase file name to extract friend's public key: " passphrase_file
                extract_public_key $pem_file $passphrase_file
                read -p "${RESET}${GREEN}Enter secret key file name to be encrypted: " secret_key
                #read -p "Enter friend's public key file name to encrypt secret key: " public_key
                asym_encrypt_file $secret_key $pub_name
            ;;
            "$option5")
                read -p "${RESET}${GREEN}Enter pem file name to use friend's private key: " pem_file
                read -p "${RESET}${GREEN}Enter passphrase file name to decrypt encrypted secret key: " passphrase_file
                read -p "${RESET}${GREEN}Enter encrpyted secret key file name to decrypt it: " enc_secret_key
                asym_decrypt_file $pem_file $passphrase_file $enc_secret_key
            ;;
            "$option6")
                read -p "${RESET}${GREEN}Enter secret key file name: " secret_key
                read -p "${RESET}${GREEN}Enter encrpyted file name to decrypt with specified secret key: " file
                sym_decrypt_file $secret_key $file
            ;;
            "$option7")
                break
            ;;
            *) echo "invalid option $REPLY";;
        esac
    done
    
}

menu
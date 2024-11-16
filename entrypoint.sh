#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"


# # Directorio de destino y versión de Odoo
# DEST_DIR="/mnt/extra-addons"
# ODOO_VERSION="15.0"
# ODOO_CONF="/etc/odoo/odoo.conf"

# # Asegurarse de que el directorio de destino existe
# # echo "Creando el directorio $DEST_DIR si no existe..."
# # mkdir -p "$DEST_DIR"

# # Lista de repositorios
# REPOS=(
#   "https://github.com/reingart/pyafipws.git"
#   "https://github.com/ingadhoc/odoo-argentina-ce.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/odoo-argentina.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/account-payment.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/argentina-sale.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/aeroo_reports.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/purchase.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/sale.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/stock.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/partner.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/product.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/account-analytic.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/account-invoicing.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/account-financial-tools.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/account-financial-reporting.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/sale-workflow.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/purchase-workflow.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/hr.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/manufacture.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/miscellaneous.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/multi-company.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/project.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/account-financial-tools.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/ingadhoc/website.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/account-payment.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/account-closing.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/bank-payment.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/hr.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/webkit-tools.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/product-attribute.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/social.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/timesheet.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/crm.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/rma.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/currency.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/website.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/pos.git -b $ODOO_VERSION --single-branch"
#   "https://github.com/OCA/web.git -b $ODOO_VERSION --single-branch"
# )

# echo "Clonando repositorios en $DEST_DIR..."
# cd "$DEST_DIR"

# # Iterar sobre la lista de repositorios
# for REPO in "${REPOS[@]}"; do
#   REPO_URL=$(echo "$REPO" | awk '{print $1}')  # Extraer la URL base
#   REPO_USER=$(echo "$REPO_URL" | awk -F'/' '{print $(NF-1)}')  # Extraer el usuario
#   REPO_NAME=$(basename "$REPO_URL" .git)  # Extraer el nombre del repositorio
  
#   # Directorio final: incluir el usuario en la estructura
#   REPO_DIR="${DEST_DIR}/${REPO_USER}/${REPO_NAME}"

#   if [ -d "$REPO_DIR" ]; then
#     echo "El repositorio $REPO_NAME ya existe en $REPO_DIR, omitiendo clonación."
#   else
#     echo "Clonando $REPO_URL en $REPO_DIR..."
#     mkdir -p "$(dirname "$REPO_DIR")"  # Crear la estructura del directorio si no existe

#     # Intentar clonar el repositorio con manejo de errores
#     if git clone $REPO "$REPO_DIR"; then
#       echo "Repositorio $REPO_NAME clonado exitosamente."
#     else
#       echo "Error al clonar $REPO_URL. Verifica la URL o la conexión a Internet."
#       continue  # Saltar al siguiente repositorio
#     fi
#   fi
# done

# echo "Todos los repositorios han sido procesados."

# # Obtener todos los directorios clonados y agregar al addons_path
# echo "Configurando addons_path en $ODOO_CONF..."
# ADDONS_PATHS=$(find "$DEST_DIR" -mindepth 2 -maxdepth 2 -type d | tr '\n' ',')

# # Modificar el archivo odoo.conf
# if grep -q "^addons_path" "$ODOO_CONF"; then
#   sed -i "s|^addons_path *=.*|addons_path = /mnt/extra-addons,$ADDONS_PATHS|" "$ODOO_CONF"
# else
#   echo "addons_path = /mnt/extra-addons,$ADDONS_PATHS" >> "$ODOO_CONF"
# fi

# echo "addons_path configurado correctamente en $ODOO_CONF."

# # Encuentra todos los archivos requirements.txt dentro del volumen
# REQUIREMENTS_FILES=$(find /mnt/extra-addons/ -name "requirements.txt")

# # Verifica si se encontraron archivos requirements.txt
# if [ -z "$REQUIREMENTS_FILES" ]; then
#     echo "No se encontraron archivos requirements.txt en /mnt/extra-addons/"
# else
#     # Itera sobre cada archivo encontrado y ejecuta pip3 install
#     pip3 install pip --upgrade
#     for FILE in $REQUIREMENTS_FILES; do
#         echo "Instalando dependencias desde $FILE..."
#         pip3 install -r "$FILE"
#     done
# fi

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
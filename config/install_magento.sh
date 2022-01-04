#!/bin/bash

if [[ -e ./pub/index.php ]]; then
        echo "Already extracted Magento"
else
        tar -xf magento.tar.gz --strip-components 1
        rm magento.tar.gz
fi

#TODO Implement the rest of the script from run.sh

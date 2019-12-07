#!/bin/bash
# 基于OpenSSL自建CA和颁发SSL证书
# https://github.com/dendi875/Linux/blob/master/%E4%BD%BF%E7%94%A8openssl%E8%87%AA%E5%BB%BACA%E5%92%8C%E9%A2%81%E5%8F%91%E5%A4%9A%E5%9F%9F%E5%90%8D%E9%80%9A%E9%85%8D%E7%AC%A6%E8%AF%81%E4%B9%A6.md

if [ ! -d "CA" ]; then
	mkdir CA
	pushd CA > /dev/null
	mkdir private
	# 在CA目录下创建两个初始文件
	touch index.txt
	echo 01 > serial
	# 生成CA证书的RSA私钥
	openssl genrsa -out private/ca.key 2048
	# 利用CA的RSA密钥生成CA证书请求并对CA证书请求进行自签名，得到CA证书(X.509结构)
	openssl req -new -sha256 -x509 -days 3650 \
	            -key private/ca.key \
	            -subj "//C=CN\ST=ShangHai\L=ShangHai\O=Zhangquan\OU=PHP\CN=Test Root CA" \
	            -out cacert.crt
	popd > /dev/null
fi

if [ -f "tls/private/nginx.key" ]; then
	rm tls/private/nginx.key
fi

if [ -f "tls/private/nginx.csr" ]; then
	rm tls/private/nginx.csr
fi

if [ -f "tls/certs/nginx.crt" ]; then
	rm tls/certs/nginx.crt
fi

# 生成服务器证书用的RSA私钥
openssl genrsa -out tls/private/nginx.key 2048

# 利用生成好的私钥生成服务器证书签名请求文件
openssl req -new \
			-sha256 \
			-key tls/private/nginx.key \
			-subj "//C=CN\ST=ShangHai\L=ShangHai\O=Zhangquan\OU=PHP\CN=Test Internal" \
			-out tls/private/nginx.csr

# 使用CA根证书对“服务器证书签名请求文件”进行签名，生成带SAN扩展证书
openssl x509 -req -sha256 \
			 -in tls/private/nginx.csr \
			 -CA CA/cacert.crt \
			 -CAkey CA/private/ca.key \
			 -CAcreateserial \
			 -days 3650 \
			 -extfile v3.ext \
			 -out tls/certs/nginx.crt

cp -f tls/certs/nginx.crt ../root/etc/nginx/ssl/zhangquan-dev.crt
cp -f tls/private/nginx.key ../root/etc/nginx/ssl/zhangquan-dev.key
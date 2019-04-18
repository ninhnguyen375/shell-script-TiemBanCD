#!bin/bash
### NOTE:
## Split a line to an Array by ":"
# Array[0] : ID
# Array[1] : Ten bai hat
# Array[2] : Ten tac gia
# Array[3] : The loai
# Array[4] : Gia
# Array[5] : So luong

themCD() {
  local data=$1
  local tenBaiHat
  local tenTacGia
  local theLoai
  local gia
  local soLuong

  while
    read -p "Nhap ten bai hat : " tenBaiHat
    [ -z "$tenBaiHat" ]
  do :; done

  while
    read -p "Nhap ten tac gia : " tenTacGia
    [ -z "$tenTacGia" ]
  do :; done

  while
    read -p "Nhap the loai : " theLoai
    [ -z "$theLoai" ]
  do :; done

  while
    read -p "Nhap Gia : " gia
    [ -z "$gia" ]
  do :; done

  while
    read -p "Nhap so luong : " soLuong
    [ -z "$soLuong" ]
  do :; done

  local str=`tail -1 $data`
  local id="${str:0:1}"
  local newId=$(( $id+1 ))
  echo "$newId:$tenBaiHat:$tenTacGia:$theLoai:$gia:$soLuong" >> $data
}

hienThiThongTinCDNganGon() {
  local data=$1
  local ARR
  local line
  local IFS=':'

  while read -r line
  do
    read -ra ARR <<< "$line"
    echo "ID:${ARR[0]} - CD : ${ARR[1]} - ${ARR[4]}VND"
  done < $data
}

hienThiThongTinCDDayDu() {
  local data=$1
  local line
  local ARR

  while read -r line
  do
    IFS=':'
    read -ra ARR <<< "$line"
    echo "-------------------------------"
    echo "ID : ${ARR[0]}"
    echo "Ten bai hat : ${ARR[1]}"
    echo "Tac gia : ${ARR[2]}"
    echo "The loai : ${ARR[3]}"
    echo "Gia : ${ARR[4]}"
    echo "So luong : ${ARR[5]}"
    echo "-------------------------------"
  done < $data
}

timCDTheoTheLoai() {
  local data=$1
  local theLoai
  
  read -p "Nhap the loai can tim : " theLoai

  echo "=> Ket qua :"
  grep -i ".*:.*:.*$theLoai.*" $data > ./search-result
  hienThiThongTinCDDayDu ./search-result
}

timCDTheoTacGia() {
  local data=$1
  local tacGia
  
  read -p "Nhap tac gia can tim : " tacGia
  echo "=> Ket qua :"
  grep -i ".*:.*$tacGia.*:.*" $data > ./search-result
  hienThiThongTinCDDayDu ./search-result
}

timCDTheoTenBaiHat() {
  local data=$1
  local TenBaiHat

  read -p "Nhap ten bai hat can tim : " TenBaiHat
  echo "=> Ket qua :"
  grep -i ".*:.*$TenBaiHat.*:" $data > ./search-result
  hienThiThongTinCDDayDu ./search-result
}

banMotLoaiCD(){  
  local data=$1
  local id
  local ARR
  local soLuong

  hienThiThongTinCDNganGon $data
  
  while
    read -p "Chon CD can ban(Nhap so ID) : " id
    [ -z $id ]
  do :; done

  local CD=`grep "$id:.*" $data`
  local IFS=':' # split string to array by ":"
  read -ra ARR <<< "$CD"
  local soLuongHienTai="${ARR[5]}"

  while [[ -z $soLuong || $soLuongHienTai -lt $soLuong ]]
  do 
    read -p "Nhap so luong can mua : " soLuong
    if [[ $soLuongHienTai -lt $soLuong ]]
    then
      echo "K du hang!"
    fi
  done

  local tongTien=$(( $soLuong * ${ARR[4]}))
  local conLai=$(( $soLuongHienTai-$soLuong ))
  local updateCD="${ARR[0]}:${ARR[1]}:${ARR[2]}:${ARR[3]}:${ARR[4]}:$conLai"

  #  update db
  sed -i '/'"${id}"':.*/c\'"${updateCD}"'' $data

  echo "$id:${ARR[1]}:$soLuong:$tongTien" >> ./don-hang
}

banCD(){
  local data=$1
  local confirm="y"

  # init don-hang
  rm ./don-hang
  touch ./don-hang

  while [[ "$confirm" == "y" ]]
  do
    banMotLoaiCD $data
    read -p "Ban co muon tiep tuc mua (y/n) : " confirm
  done

  inHoaDonBanHang
}

inHoaDonBanHang() {
  local tongTien=0
  local ARR
  local IFS=":"
  while read -r line
  do
    read -ra ARR <<< "$line"
    tongTien=$(($tongTien+${ARR[3]}))
  done < ./don-hang

  echo ">---------------------< HOA DON >---------------------<" | lolcat

  while read -r line
  do
    read -ra ARR <<< "$line"
    echo "CD:${ARR[1]} | So luonng:${ARR[2]} | ${ARR[3]}VND"
  done < ./don-hang
  echo ""
  echo "TONG TIEN : $tongTien VND"
  echo "-------------------------------------------------------" | lolcat
}

while true
do
  echo "$(figlet 'Tiem Ban CD')" | lolcat
  echo "1) Them CD"
  echo "2) Hien Thi Thong Tin CD Ngan Gon"
  echo "3) Hien Thi Thong Tin CD Day Du"
  echo "4) Tim CD Theo The Loai"
  echo "5) Tim CD Theo Tac Gia"
  echo "6) Tim CD Theo Ten Bai Hat"
  echo "7) Ban CD"
  # echo "8) In Hoa Don Ban Hang"
  echo "0) Thoat"
  read -p "Choose : " choose
  fileData=./db
  case $choose in
    1)
      themCD $fileData
      hienThiThongTinCDDayDu $fileData
    ;;
    2)
      hienThiThongTinCDNganGon $fileData
    ;;
    3)
      hienThiThongTinCDDayDu $fileData
    ;;
    4)
      timCDTheoTheLoai $fileData
    ;;
    5)
      timCDTheoTacGia $fileData
    ;;
    6)
      timCDTheoTenBaiHat $fileData
    ;;
    7)
      banCD $fileData
    ;;
    'exit'|0) echo "Bye!" && exit
    ;;
    *) echo "Can not read your choose"
    ;;
  esac
  
  echo "Enter to Continute"
  read temp
done

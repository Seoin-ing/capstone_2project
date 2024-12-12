import os

# 원본 CSV 파일이 있는 디렉토리
input_directory = "C:/Users/User/Desktop/project/assets/csv_ori"
# 출력 디렉토리
output_directory = "C:/Users/User/Desktop/project/assets/csv"
# 매핑 정보를 저장할 파일 경로
mapping_file = "C:/Users/User/Desktop/project/assets/csv/csv_mapping.txt"

# 출력 디렉토리가 없으면 생성
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# 매핑 정보를 저장할 딕셔너리
mapping = {}

# 디렉토리 내 CSV 파일 처리
csv_files = [file for file in os.listdir(input_directory) if file.endswith(".csv")]
for index, file_name in enumerate(csv_files, start=1):
    original_path = os.path.join(input_directory, file_name)
    new_file_name = f"{index}.csv"
    new_path = os.path.join(output_directory, new_file_name)

    # 파일 이름 변경
    os.rename(original_path, new_path)

    # 매핑 정보 추가
    mapping[f"csv/{new_file_name}"] = file_name.rsplit(".", 1)[0]  # 확장자 제거

# 매핑 정보를 메모장에 저장
with open(mapping_file, "w", encoding="utf-8") as file:
    for new_name, original_name in mapping.items():
        file.write(f"'{new_name}': '{original_name}',\n")

print("CSV 파일 이름 변경 완료 및 매핑 저장 완료!")

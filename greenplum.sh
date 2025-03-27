#!/bin/bash

SERVER_IP=$1
USERNAME=$2
PASSWORD=$3
FILE_PATH=$4

scp "$FILE_PATH" "$USERNAME@$SERVER_IP:~/"

ssh "$USERNAME@$SERVER_IP" << EOF

gpfdist -d ~/ -p 8083 &

sed -i '1d' ~/$(basename "$FILE_PATH")

psql -d idp -c "CREATE EXTERNAL TABLE student_stress_data (
    student_id VARCHAR(20),
    age INT,
    gender VARCHAR(30),
    academic_performance_gpa FLOAT,
    study_hours_per_week INT,
    social_media_usage_hours_per_day INT,
    sleep_duration_hours_per_night INT,
    physical_exercise_hours_per_week INT,
    family_support INT,
    financial_stress INT,
    peer_pressure INT,
    relationship_stress INT,
    mental_stress_level INT,
    counseling_attendance VARCHAR(5),
    diet_quality INT,
    stress_coping_mechanisms VARCHAR(100),
    cognitive_distortions INT,
    family_mental_health_history VARCHAR(3),
    medical_condition VARCHAR(3),
    substance_use INT
) LOCATION ('gpfdist://localhost:8083/$(basename "$FILE_PATH")') FORMAT 'CSV';"

psql -d idp -c "SELECT * FROM student_stress_data;"
EOF
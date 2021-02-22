#### Q1. IS 와 "="의 차이점은?
"IS"는 Boolean 값을 확인하기 위한 연산자이고,<br>
"="은 Value(값)이 일치하는지 확인하기 위한 연산자입니다.<br>
이들의 명확한 차이는 IS 연산자는 True 혹은 False만을 반환하고 = 연산자는 True, False 와 더불어 Unknown 상태도 리턴한다는 점입니다.<br>
true = unknown 의 결과는 unknown 입니다. = 연산자는 unknown이라는 값을 가질 수 없기 때문입니다.<br>
true is unknown 의 결과는 false 입니다. boolean 연산자는 unknown이라는 값을 가지고 있으므로 둘이 명백히 다르기 때문입니다.<br>
<br>

#### Q2. 짝수 결과만을 얻기 위해 사용하는 함수는?
MOD 함수. (ex> "select * from table where MOD(column,2)=0 )<br>
<br>

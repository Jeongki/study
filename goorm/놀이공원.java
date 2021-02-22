import java.io.*;
import java.lang.*;
import java.util.*;

/* 최초에 설정된 좌표가 0,0 일 때, 이를 대각선으로 이동하는 방식으로 검색을 하도록 했다.
 * for 문을 3번 사용하는 방식 말고 다른 방식을 알아내고 싶다.
 */

public class Main {
	public static final Scanner scanner = new Scanner(System.in);
	
	public static void testCase(int caseIndex) {
		int N = scanner.nextInt();  // 지도의 크기 
		int K = scanner.nextInt();  // 놀이공원의 크기
		
		int[][] wastes = new int[N][N]; // 각 칸의 쓰레기 존재 여부 
		for (int r = 0; r < N; r += 1) {
			for (int c = 0; c < N; c += 1) {
				// wastes[r][c] = scanner.nextInt();
				wastes[c][r] = scanner.nextInt();
			}
		}
		
		int answer = Integer.MAX_VALUE;

		int fnd = 0;
		int line = 0;
		
		// n*(n*n+n*n) = n*2n^2 = 2n^3 = n^3
	  for(int x = 0; x + K <= N; x++){ // 0,0 -> 1,1 -> 2,2 -> ...
			for(int i = x; i + K <= N; i++){ // Going right
				int col = x;
				for(int t = i; t < K + i; ){ // sum
					fnd += wastes[t][col];
					
					if(t == K - 1 + i){
						t = i;
						col++;
						line++;
						
						if(line == K){
							line = 0;
							break;
						}else{
							continue;
						}
					}
					t++;
				}
				
				if (fnd < answer){
					answer = fnd;
				}
				fnd = 0;
			}
			
			for(int j = x + 1; j + K <= N; j++){ // Going down
				int col = x;
				for(int t = j; t < K + j; ){ // sum
					fnd += wastes[col][t];
					
					if(t == K - 1 + j){
						t = j;
						col++;
						line++;
						
						if(line == K){
							line = 0;
							break;
						}else{
							continue;
						}
					}
					t++;
				}
				
				if (fnd < answer){
					answer = fnd;
				}
				fnd = 0;
			}
		}
		
		System.out.println(answer);
	}
	
	public static void main(String[] args) throws Exception {
		int caseSize = scanner.nextInt();
		
		for (int caseIndex = 1; caseIndex <= caseSize; caseIndex += 1) {
			testCase(caseIndex);
		}
	}
}

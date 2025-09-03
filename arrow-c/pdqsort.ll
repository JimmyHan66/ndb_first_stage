; ModuleID = 'pdqsort.c'
source_filename = "pdqsort.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@__const.generate_duplicate_array.values = private unnamed_addr constant [5 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5], align 16
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.2 = private unnamed_addr constant [3 x i8] c", \00", align 1
@.str.4 = private unnamed_addr constant [5 x i8] c"\22%s\22\00", align 1
@__const.main.arr1 = private unnamed_addr constant [11 x i32] [i32 64, i32 34, i32 25, i32 12, i32 22, i32 11, i32 90, i32 88, i32 76, i32 50, i32 42], align 16
@.str.6 = private unnamed_addr constant [11 x i8] c"Original: \00", align 1
@.str.7 = private unnamed_addr constant [11 x i8] c"Sorted:   \00", align 1
@.str.9 = private unnamed_addr constant [12 x i8] c"Original: [\00", align 1
@.str.10 = private unnamed_addr constant [5 x i8] c"%.2f\00", align 1
@.str.11 = private unnamed_addr constant [12 x i8] c"Sorted:   [\00", align 1
@.str.14 = private unnamed_addr constant [26 x i8] c"Done! First 10 elements: \00", align 1
@.str.15 = private unnamed_addr constant [4 x i8] c"%d \00", align 1
@.str.18 = private unnamed_addr constant [6 x i8] c"apple\00", align 1
@.str.19 = private unnamed_addr constant [7 x i8] c"banana\00", align 1
@.str.20 = private unnamed_addr constant [7 x i8] c"cherry\00", align 1
@.str.21 = private unnamed_addr constant [5 x i8] c"date\00", align 1
@.str.22 = private unnamed_addr constant [11 x i8] c"elderberry\00", align 1
@.str.23 = private unnamed_addr constant [4 x i8] c"fig\00", align 1
@.str.24 = private unnamed_addr constant [6 x i8] c"grape\00", align 1
@.str.25 = private unnamed_addr constant [9 x i8] c"honeydew\00", align 1
@.str.26 = private unnamed_addr constant [5 x i8] c"kiwi\00", align 1
@.str.27 = private unnamed_addr constant [6 x i8] c"lemon\00", align 1
@.str.28 = private unnamed_addr constant [6 x i8] c"mango\00", align 1
@.str.29 = private unnamed_addr constant [10 x i8] c"nectarine\00", align 1
@.str.30 = private unnamed_addr constant [7 x i8] c"orange\00", align 1
@.str.31 = private unnamed_addr constant [7 x i8] c"papaya\00", align 1
@.str.32 = private unnamed_addr constant [7 x i8] c"quince\00", align 1
@.str.33 = private unnamed_addr constant [10 x i8] c"raspberry\00", align 1
@.str.34 = private unnamed_addr constant [11 x i8] c"strawberry\00", align 1
@.str.35 = private unnamed_addr constant [10 x i8] c"tangerine\00", align 1
@.str.36 = private unnamed_addr constant [11 x i8] c"watermelon\00", align 1
@.str.37 = private unnamed_addr constant [9 x i8] c"zucchini\00", align 1
@__const.main.words = private unnamed_addr constant [20 x ptr] [ptr @.str.18, ptr @.str.19, ptr @.str.20, ptr @.str.21, ptr @.str.22, ptr @.str.23, ptr @.str.24, ptr @.str.25, ptr @.str.26, ptr @.str.27, ptr @.str.28, ptr @.str.29, ptr @.str.30, ptr @.str.31, ptr @.str.32, ptr @.str.33, ptr @.str.34, ptr @.str.35, ptr @.str.36, ptr @.str.37], align 16
@.str.39 = private unnamed_addr constant [11 x i8] c"By length:\00", align 1
@str.41 = private unnamed_addr constant [31 x i8] c"Testing pdqsort with integers:\00", align 1
@str.42 = private unnamed_addr constant [31 x i8] c"\0ATesting pdqsort with doubles:\00", align 1
@str.44 = private unnamed_addr constant [2 x i8] c"]\00", align 1
@str.45 = private unnamed_addr constant [44 x i8] c"\0ATesting with larger array (1000 elements):\00", align 1
@str.46 = private unnamed_addr constant [32 x i8] c"Sorting 1000 random integers...\00", align 1
@str.47 = private unnamed_addr constant [56 x i8] c"\0ATesting pdqsort with English words (dictionary order):\00", align 1
@str.48 = private unnamed_addr constant [46 x i8] c"\0ATesting pdqsort with words sorted by length:\00", align 1

; Function Attrs: nounwind uwtable
define dso_local void @pdqsort(ptr noundef %0, i64 noundef %1, i64 noundef %2, ptr noundef %3) local_unnamed_addr #0 {
  %5 = icmp ult i64 %1, 2
  br i1 %5, label %14, label %6

6:                                                ; preds = %4, %6
  %7 = phi i64 [ %9, %6 ], [ %1, %4 ]
  %8 = phi i32 [ %10, %6 ], [ 0, %4 ]
  %9 = lshr i64 %7, 1
  %10 = add nuw nsw i32 %8, 1
  %11 = icmp ugt i64 %7, 3
  br i1 %11, label %6, label %12, !llvm.loop !5

12:                                               ; preds = %6
  %13 = add i64 %1, -1
  tail call fastcc void @pdqsort_loop(ptr noundef %0, i64 noundef 0, i64 noundef %13, i64 noundef %2, ptr noundef %3, i32 noundef %10, i1 noundef zeroext true)
  br label %14

14:                                               ; preds = %4, %12
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind uwtable
define internal fastcc void @pdqsort_loop(ptr noundef %0, i64 noundef %1, i64 noundef %2, i64 noundef %3, ptr noundef %4, i32 noundef %5, i1 noundef zeroext %6) unnamed_addr #0 {
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i64, align 8
  %13 = alloca i64, align 8
  %14 = sub i64 %2, %1
  %15 = add i64 %14, 1
  %16 = icmp ult i64 %15, 25
  br i1 %16, label %20, label %17

17:                                               ; preds = %7
  %18 = zext i1 %6 to i8
  %19 = icmp ult i64 %3, 9
  br label %50

20:                                               ; preds = %405, %7
  %21 = phi i64 [ %2, %7 ], [ %407, %405 ]
  %22 = phi i64 [ %1, %7 ], [ %408, %405 ]
  %23 = add i64 %22, 1
  %24 = icmp ugt i64 %23, %21
  br i1 %24, label %412, label %25

25:                                               ; preds = %20, %45
  %26 = phi i64 [ %48, %45 ], [ %23, %20 ]
  %27 = mul i64 %26, %3
  %28 = getelementptr inbounds i8, ptr %0, i64 %27
  %29 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %29, ptr align 1 %28, i64 %3, i1 false)
  %30 = icmp ugt i64 %26, %22
  br i1 %30, label %31, label %45

31:                                               ; preds = %25, %38
  %32 = phi i64 [ %33, %38 ], [ %26, %25 ]
  %33 = add i64 %32, -1
  %34 = mul i64 %33, %3
  %35 = getelementptr inbounds i8, ptr %0, i64 %34
  %36 = tail call i32 %4(ptr noundef %35, ptr noundef %29) #17
  %37 = icmp sgt i32 %36, 0
  br i1 %37, label %38, label %42

38:                                               ; preds = %31
  %39 = mul i64 %32, %3
  %40 = getelementptr inbounds i8, ptr %0, i64 %39
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %40, ptr align 1 %35, i64 %3, i1 false)
  %41 = icmp ugt i64 %33, %22
  br i1 %41, label %31, label %42, !llvm.loop !7

42:                                               ; preds = %38, %31
  %43 = phi i64 [ %32, %31 ], [ %22, %38 ]
  %44 = mul i64 %43, %3
  br label %45

45:                                               ; preds = %42, %25
  %46 = phi i64 [ %44, %42 ], [ %27, %25 ]
  %47 = getelementptr inbounds i8, ptr %0, i64 %46
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %47, ptr align 1 %29, i64 %3, i1 false)
  tail call void @free(ptr noundef %29) #17
  %48 = add i64 %26, 1
  %49 = icmp ugt i64 %48, %21
  br i1 %49, label %412, label %25, !llvm.loop !8

50:                                               ; preds = %17, %405
  %51 = phi i64 [ %15, %17 ], [ %410, %405 ]
  %52 = phi i64 [ %1, %17 ], [ %408, %405 ]
  %53 = phi i64 [ %2, %17 ], [ %407, %405 ]
  %54 = phi i32 [ %5, %17 ], [ %397, %405 ]
  %55 = phi i8 [ %18, %17 ], [ %406, %405 ]
  %56 = and i8 %55, 1
  %57 = icmp ne i8 %56, 0
  br i1 %57, label %58, label %101

58:                                               ; preds = %50
  %59 = add i64 %52, 1
  %60 = icmp ugt i64 %59, %53
  br i1 %60, label %412, label %61

61:                                               ; preds = %58, %94
  %62 = phi i64 [ %96, %94 ], [ %59, %58 ]
  %63 = phi i64 [ %95, %94 ], [ 0, %58 ]
  %64 = phi i64 [ %62, %94 ], [ %52, %58 ]
  %65 = mul i64 %62, %3
  %66 = getelementptr inbounds i8, ptr %0, i64 %65
  %67 = mul i64 %64, %3
  %68 = getelementptr inbounds i8, ptr %0, i64 %67
  %69 = tail call i32 %4(ptr noundef %68, ptr noundef %66) #17
  %70 = icmp slt i32 %69, 1
  br i1 %70, label %94, label %71

71:                                               ; preds = %61
  %72 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %72, ptr align 1 %66, i64 %3, i1 false)
  %73 = icmp ugt i64 %62, %52
  br i1 %73, label %74, label %88

74:                                               ; preds = %71, %81
  %75 = phi i64 [ %76, %81 ], [ %62, %71 ]
  %76 = add i64 %75, -1
  %77 = mul i64 %76, %3
  %78 = getelementptr inbounds i8, ptr %0, i64 %77
  %79 = tail call i32 %4(ptr noundef %78, ptr noundef %72) #17
  %80 = icmp slt i32 %79, 1
  br i1 %80, label %85, label %81

81:                                               ; preds = %74
  %82 = mul i64 %75, %3
  %83 = getelementptr inbounds i8, ptr %0, i64 %82
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %83, ptr align 1 %78, i64 %3, i1 false)
  %84 = icmp ugt i64 %76, %52
  br i1 %84, label %74, label %85, !llvm.loop !9

85:                                               ; preds = %81, %74
  %86 = phi i64 [ %52, %81 ], [ %75, %74 ]
  %87 = mul i64 %86, %3
  br label %88

88:                                               ; preds = %85, %71
  %89 = phi i64 [ %87, %85 ], [ %65, %71 ]
  %90 = phi i64 [ %86, %85 ], [ %62, %71 ]
  %91 = getelementptr inbounds i8, ptr %0, i64 %89
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %91, ptr align 1 %72, i64 %3, i1 false)
  tail call void @free(ptr noundef %72) #17
  %92 = add i64 %63, %62
  %93 = sub i64 %92, %90
  br label %94

94:                                               ; preds = %88, %61
  %95 = phi i64 [ %93, %88 ], [ %63, %61 ]
  %96 = add i64 %62, 1
  %97 = icmp ugt i64 %96, %53
  %98 = icmp ugt i64 %95, 8
  %99 = select i1 %97, i1 true, i1 %98
  br i1 %99, label %100, label %61, !llvm.loop !10

100:                                              ; preds = %94
  br i1 %97, label %412, label %101

101:                                              ; preds = %100, %50
  %102 = icmp eq i32 %54, 0
  br i1 %102, label %103, label %205

103:                                              ; preds = %101
  %104 = icmp ugt i64 %53, %52
  br i1 %104, label %105, label %412

105:                                              ; preds = %103
  %106 = xor i64 %52, -1
  %107 = add i64 %53, %106
  %108 = lshr i64 %107, 1
  br label %113

109:                                              ; preds = %153
  %110 = mul i64 %52, %3
  %111 = getelementptr inbounds i8, ptr %0, i64 %110
  %112 = shl i64 %52, 1
  br label %156

113:                                              ; preds = %153, %105
  %114 = phi i64 [ %108, %105 ], [ %154, %153 ]
  %115 = add i64 %114, %52
  %116 = shl i64 %115, 1
  %117 = icmp ult i64 %116, %53
  br i1 %117, label %118, label %153

118:                                              ; preds = %113, %150
  %119 = phi i64 [ %151, %150 ], [ %116, %113 ]
  %120 = phi i64 [ %140, %150 ], [ %115, %113 ]
  %121 = or disjoint i64 %119, 1
  %122 = mul i64 %120, %3
  %123 = getelementptr inbounds i8, ptr %0, i64 %122
  %124 = mul i64 %121, %3
  %125 = getelementptr inbounds i8, ptr %0, i64 %124
  %126 = tail call i32 %4(ptr noundef %123, ptr noundef %125) #17
  %127 = icmp slt i32 %126, 0
  %128 = select i1 %127, i64 %121, i64 %120
  %129 = add i64 %119, 2
  %130 = icmp ugt i64 %129, %53
  br i1 %130, label %139, label %131

131:                                              ; preds = %118
  %132 = mul i64 %128, %3
  %133 = getelementptr inbounds i8, ptr %0, i64 %132
  %134 = mul i64 %129, %3
  %135 = getelementptr inbounds i8, ptr %0, i64 %134
  %136 = tail call i32 %4(ptr noundef %133, ptr noundef %135) #17
  %137 = icmp slt i32 %136, 0
  %138 = select i1 %137, i64 %129, i64 %128
  br label %139

139:                                              ; preds = %131, %118
  %140 = phi i64 [ %128, %118 ], [ %138, %131 ]
  %141 = icmp eq i64 %140, %120
  br i1 %141, label %153, label %142

142:                                              ; preds = %139
  %143 = mul i64 %140, %3
  %144 = getelementptr inbounds i8, ptr %0, i64 %143
  %145 = icmp eq i64 %122, %143
  br i1 %145, label %150, label %146

146:                                              ; preds = %142
  br i1 %19, label %147, label %148

147:                                              ; preds = %146
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %13)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %13, ptr align 1 %123, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %123, ptr align 1 %144, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %144, ptr nonnull align 8 %13, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %13)
  br label %150

148:                                              ; preds = %146
  %149 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %149, ptr align 1 %123, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %123, ptr align 1 %144, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %144, ptr align 1 %149, i64 %3, i1 false)
  tail call void @free(ptr noundef %149) #17
  br label %150

150:                                              ; preds = %148, %147, %142
  %151 = shl i64 %140, 1
  %152 = icmp ult i64 %151, %53
  br i1 %152, label %118, label %153

153:                                              ; preds = %150, %139, %113
  %154 = add nsw i64 %114, -1
  %155 = icmp eq i64 %114, 0
  br i1 %155, label %109, label %113, !llvm.loop !11

156:                                              ; preds = %203, %109
  %157 = phi i64 [ %53, %109 ], [ %166, %203 ]
  %158 = mul i64 %157, %3
  %159 = getelementptr inbounds i8, ptr %0, i64 %158
  %160 = icmp eq i64 %110, %158
  br i1 %160, label %165, label %161

161:                                              ; preds = %156
  br i1 %19, label %162, label %163

162:                                              ; preds = %161
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %12)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %12, ptr align 1 %111, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %111, ptr align 1 %159, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %159, ptr nonnull align 8 %12, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %12)
  br label %165

163:                                              ; preds = %161
  %164 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %164, ptr align 1 %111, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %111, ptr align 1 %159, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %159, ptr align 1 %164, i64 %3, i1 false)
  tail call void @free(ptr noundef %164) #17
  br label %165

165:                                              ; preds = %163, %162, %156
  %166 = add i64 %157, -1
  %167 = icmp ult i64 %112, %166
  br i1 %167, label %168, label %203

168:                                              ; preds = %165, %200
  %169 = phi i64 [ %201, %200 ], [ %112, %165 ]
  %170 = phi i64 [ %190, %200 ], [ %52, %165 ]
  %171 = or disjoint i64 %169, 1
  %172 = mul i64 %170, %3
  %173 = getelementptr inbounds i8, ptr %0, i64 %172
  %174 = mul i64 %171, %3
  %175 = getelementptr inbounds i8, ptr %0, i64 %174
  %176 = tail call i32 %4(ptr noundef %173, ptr noundef %175) #17
  %177 = icmp slt i32 %176, 0
  %178 = select i1 %177, i64 %171, i64 %170
  %179 = add i64 %169, 2
  %180 = icmp ugt i64 %179, %166
  br i1 %180, label %189, label %181

181:                                              ; preds = %168
  %182 = mul i64 %178, %3
  %183 = getelementptr inbounds i8, ptr %0, i64 %182
  %184 = mul i64 %179, %3
  %185 = getelementptr inbounds i8, ptr %0, i64 %184
  %186 = tail call i32 %4(ptr noundef %183, ptr noundef %185) #17
  %187 = icmp slt i32 %186, 0
  %188 = select i1 %187, i64 %179, i64 %178
  br label %189

189:                                              ; preds = %181, %168
  %190 = phi i64 [ %178, %168 ], [ %188, %181 ]
  %191 = icmp eq i64 %190, %170
  br i1 %191, label %203, label %192

192:                                              ; preds = %189
  %193 = mul i64 %190, %3
  %194 = getelementptr inbounds i8, ptr %0, i64 %193
  %195 = icmp eq i64 %172, %193
  br i1 %195, label %200, label %196

196:                                              ; preds = %192
  br i1 %19, label %197, label %198

197:                                              ; preds = %196
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %11)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %11, ptr align 1 %173, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %173, ptr align 1 %194, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %194, ptr nonnull align 8 %11, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %11)
  br label %200

198:                                              ; preds = %196
  %199 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %199, ptr align 1 %173, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %173, ptr align 1 %194, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %194, ptr align 1 %199, i64 %3, i1 false)
  tail call void @free(ptr noundef %199) #17
  br label %200

200:                                              ; preds = %198, %197, %192
  %201 = shl i64 %190, 1
  %202 = icmp ult i64 %201, %166
  br i1 %202, label %168, label %203

203:                                              ; preds = %200, %189, %165
  %204 = icmp ugt i64 %166, %52
  br i1 %204, label %156, label %412, !llvm.loop !12

205:                                              ; preds = %101
  %206 = icmp ugt i64 %51, 128
  br i1 %206, label %207, label %310

207:                                              ; preds = %205
  %208 = lshr i64 %51, 3
  %209 = add i64 %208, %52
  %210 = shl nuw nsw i64 %208, 1
  %211 = add i64 %210, %52
  %212 = mul nuw nsw i64 %208, 3
  %213 = add i64 %212, %52
  %214 = shl nuw nsw i64 %208, 2
  %215 = add i64 %214, %52
  %216 = mul nuw i64 %208, 5
  %217 = add i64 %216, %52
  %218 = mul nuw i64 %208, 6
  %219 = add i64 %218, %52
  %220 = mul nuw i64 %208, 7
  %221 = add i64 %220, %52
  %222 = mul i64 %52, %3
  %223 = getelementptr inbounds i8, ptr %0, i64 %222
  %224 = mul i64 %209, %3
  %225 = getelementptr inbounds i8, ptr %0, i64 %224
  %226 = tail call i32 %4(ptr noundef %223, ptr noundef %225) #17
  %227 = icmp sgt i32 %226, 0
  %228 = select i1 %227, i64 %52, i64 %209
  %229 = select i1 %227, i64 %209, i64 %52
  %230 = mul i64 %228, %3
  %231 = getelementptr inbounds i8, ptr %0, i64 %230
  %232 = mul i64 %211, %3
  %233 = getelementptr inbounds i8, ptr %0, i64 %232
  %234 = tail call i32 %4(ptr noundef %231, ptr noundef %233) #17
  %235 = icmp sgt i32 %234, 0
  %236 = select i1 %235, i64 %211, i64 %228
  %237 = mul i64 %229, %3
  %238 = getelementptr inbounds i8, ptr %0, i64 %237
  %239 = mul i64 %236, %3
  %240 = getelementptr inbounds i8, ptr %0, i64 %239
  %241 = tail call i32 %4(ptr noundef %238, ptr noundef %240) #17
  %242 = icmp sgt i32 %241, 0
  %243 = select i1 %242, i64 %229, i64 %236
  %244 = mul i64 %213, %3
  %245 = getelementptr inbounds i8, ptr %0, i64 %244
  %246 = mul i64 %215, %3
  %247 = getelementptr inbounds i8, ptr %0, i64 %246
  %248 = tail call i32 %4(ptr noundef %245, ptr noundef %247) #17
  %249 = icmp sgt i32 %248, 0
  %250 = select i1 %249, i64 %213, i64 %215
  %251 = select i1 %249, i64 %215, i64 %213
  %252 = mul i64 %250, %3
  %253 = getelementptr inbounds i8, ptr %0, i64 %252
  %254 = mul i64 %217, %3
  %255 = getelementptr inbounds i8, ptr %0, i64 %254
  %256 = tail call i32 %4(ptr noundef %253, ptr noundef %255) #17
  %257 = icmp sgt i32 %256, 0
  %258 = select i1 %257, i64 %217, i64 %250
  %259 = mul i64 %251, %3
  %260 = getelementptr inbounds i8, ptr %0, i64 %259
  %261 = mul i64 %258, %3
  %262 = getelementptr inbounds i8, ptr %0, i64 %261
  %263 = tail call i32 %4(ptr noundef %260, ptr noundef %262) #17
  %264 = icmp sgt i32 %263, 0
  %265 = select i1 %264, i64 %251, i64 %258
  %266 = mul i64 %219, %3
  %267 = getelementptr inbounds i8, ptr %0, i64 %266
  %268 = mul i64 %221, %3
  %269 = getelementptr inbounds i8, ptr %0, i64 %268
  %270 = tail call i32 %4(ptr noundef %267, ptr noundef %269) #17
  %271 = icmp sgt i32 %270, 0
  %272 = select i1 %271, i64 %219, i64 %221
  %273 = select i1 %271, i64 %221, i64 %219
  %274 = mul i64 %272, %3
  %275 = getelementptr inbounds i8, ptr %0, i64 %274
  %276 = mul i64 %53, %3
  %277 = getelementptr inbounds i8, ptr %0, i64 %276
  %278 = tail call i32 %4(ptr noundef %275, ptr noundef %277) #17
  %279 = icmp sgt i32 %278, 0
  %280 = select i1 %279, i64 %53, i64 %272
  %281 = mul i64 %273, %3
  %282 = getelementptr inbounds i8, ptr %0, i64 %281
  %283 = mul i64 %280, %3
  %284 = getelementptr inbounds i8, ptr %0, i64 %283
  %285 = tail call i32 %4(ptr noundef %282, ptr noundef %284) #17
  %286 = icmp sgt i32 %285, 0
  %287 = select i1 %286, i64 %273, i64 %280
  %288 = mul i64 %243, %3
  %289 = getelementptr inbounds i8, ptr %0, i64 %288
  %290 = mul i64 %265, %3
  %291 = getelementptr inbounds i8, ptr %0, i64 %290
  %292 = tail call i32 %4(ptr noundef %289, ptr noundef %291) #17
  %293 = icmp sgt i32 %292, 0
  %294 = select i1 %293, i64 %243, i64 %265
  %295 = select i1 %293, i64 %265, i64 %243
  %296 = mul i64 %294, %3
  %297 = getelementptr inbounds i8, ptr %0, i64 %296
  %298 = mul i64 %287, %3
  %299 = getelementptr inbounds i8, ptr %0, i64 %298
  %300 = tail call i32 %4(ptr noundef %297, ptr noundef %299) #17
  %301 = icmp sgt i32 %300, 0
  %302 = select i1 %301, i64 %287, i64 %294
  %303 = mul i64 %295, %3
  %304 = getelementptr inbounds i8, ptr %0, i64 %303
  %305 = mul i64 %302, %3
  %306 = getelementptr inbounds i8, ptr %0, i64 %305
  %307 = tail call i32 %4(ptr noundef %304, ptr noundef %306) #17
  %308 = icmp sgt i32 %307, 0
  %309 = select i1 %308, i64 %295, i64 %302
  br label %335

310:                                              ; preds = %205
  %311 = lshr i64 %51, 1
  %312 = add i64 %311, %52
  %313 = mul i64 %52, %3
  %314 = getelementptr inbounds i8, ptr %0, i64 %313
  %315 = mul i64 %312, %3
  %316 = getelementptr inbounds i8, ptr %0, i64 %315
  %317 = tail call i32 %4(ptr noundef %314, ptr noundef %316) #17
  %318 = icmp sgt i32 %317, 0
  %319 = mul i64 %53, %3
  %320 = getelementptr inbounds i8, ptr %0, i64 %319
  br i1 %318, label %321, label %328

321:                                              ; preds = %310
  %322 = tail call i32 %4(ptr noundef %316, ptr noundef %320) #17
  %323 = icmp sgt i32 %322, 0
  br i1 %323, label %335, label %324

324:                                              ; preds = %321
  %325 = tail call i32 %4(ptr noundef %314, ptr noundef %320) #17
  %326 = icmp sgt i32 %325, 0
  %327 = select i1 %326, i64 %53, i64 %52
  br label %335

328:                                              ; preds = %310
  %329 = tail call i32 %4(ptr noundef %314, ptr noundef %320) #17
  %330 = icmp sgt i32 %329, 0
  br i1 %330, label %335, label %331

331:                                              ; preds = %328
  %332 = tail call i32 %4(ptr noundef %316, ptr noundef %320) #17
  %333 = icmp sgt i32 %332, 0
  %334 = select i1 %333, i64 %53, i64 %312
  br label %335

335:                                              ; preds = %321, %324, %328, %331, %207
  %336 = phi i64 [ %313, %321 ], [ %313, %324 ], [ %313, %328 ], [ %313, %331 ], [ %222, %207 ]
  %337 = phi i64 [ %312, %321 ], [ %327, %324 ], [ %52, %328 ], [ %334, %331 ], [ %309, %207 ]
  %338 = getelementptr inbounds i8, ptr %0, i64 %336
  %339 = mul i64 %337, %3
  %340 = getelementptr inbounds i8, ptr %0, i64 %339
  %341 = icmp eq i64 %336, %339
  br i1 %341, label %346, label %342

342:                                              ; preds = %335
  br i1 %19, label %343, label %344

343:                                              ; preds = %342
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %10)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %10, ptr align 1 %338, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %338, ptr align 1 %340, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %340, ptr nonnull align 8 %10, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %10)
  br label %346

344:                                              ; preds = %342
  %345 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %345, ptr align 1 %338, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %338, ptr align 1 %340, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %340, ptr align 1 %345, i64 %3, i1 false)
  tail call void @free(ptr noundef %345) #17
  br label %346

346:                                              ; preds = %344, %343, %335
  %347 = add i64 %52, 1
  %348 = icmp ugt i64 %347, %53
  br i1 %348, label %387, label %349

349:                                              ; preds = %346, %382
  %350 = phi i64 [ %385, %382 ], [ %347, %346 ]
  %351 = phi i64 [ %384, %382 ], [ %53, %346 ]
  %352 = phi i64 [ %383, %382 ], [ %52, %346 ]
  %353 = mul i64 %350, %3
  %354 = getelementptr inbounds i8, ptr %0, i64 %353
  %355 = tail call i32 %4(ptr noundef %354, ptr noundef %338) #17
  %356 = icmp slt i32 %355, 0
  br i1 %356, label %357, label %368

357:                                              ; preds = %349
  %358 = mul i64 %352, %3
  %359 = getelementptr inbounds i8, ptr %0, i64 %358
  %360 = icmp eq i64 %358, %353
  br i1 %360, label %365, label %361

361:                                              ; preds = %357
  br i1 %19, label %362, label %363

362:                                              ; preds = %361
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %9)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %9, ptr align 1 %359, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %359, ptr align 1 %354, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %354, ptr nonnull align 8 %9, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %9)
  br label %365

363:                                              ; preds = %361
  %364 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %364, ptr align 1 %359, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %359, ptr align 1 %354, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %354, ptr align 1 %364, i64 %3, i1 false)
  tail call void @free(ptr noundef %364) #17
  br label %365

365:                                              ; preds = %363, %362, %357
  %366 = add i64 %352, 1
  %367 = add i64 %350, 1
  br label %382

368:                                              ; preds = %349
  %369 = icmp eq i32 %355, 0
  br i1 %369, label %380, label %370

370:                                              ; preds = %368
  %371 = mul i64 %351, %3
  %372 = getelementptr inbounds i8, ptr %0, i64 %371
  %373 = icmp eq i64 %353, %371
  br i1 %373, label %378, label %374

374:                                              ; preds = %370
  br i1 %19, label %375, label %376

375:                                              ; preds = %374
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %8)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 %8, ptr align 1 %354, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %354, ptr align 1 %372, i64 %3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %372, ptr nonnull align 8 %8, i64 %3, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %8)
  br label %378

376:                                              ; preds = %374
  %377 = tail call noalias ptr @malloc(i64 noundef %3) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %377, ptr align 1 %354, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %354, ptr align 1 %372, i64 %3, i1 false)
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 1 %372, ptr align 1 %377, i64 %3, i1 false)
  tail call void @free(ptr noundef %377) #17
  br label %378

378:                                              ; preds = %376, %375, %370
  %379 = add i64 %351, -1
  br label %382

380:                                              ; preds = %368
  %381 = add i64 %350, 1
  br label %382

382:                                              ; preds = %380, %378, %365
  %383 = phi i64 [ %366, %365 ], [ %352, %378 ], [ %352, %380 ]
  %384 = phi i64 [ %351, %365 ], [ %379, %378 ], [ %351, %380 ]
  %385 = phi i64 [ %367, %365 ], [ %350, %378 ], [ %381, %380 ]
  %386 = icmp ugt i64 %385, %384
  br i1 %386, label %387, label %349, !llvm.loop !13

387:                                              ; preds = %382, %346
  %388 = phi i64 [ %52, %346 ], [ %383, %382 ]
  %389 = phi i64 [ %53, %346 ], [ %384, %382 ]
  %390 = sub i64 %388, %52
  %391 = sub i64 %53, %389
  %392 = lshr i64 %51, 3
  %393 = icmp ult i64 %390, %392
  %394 = icmp ult i64 %391, %392
  %395 = or i1 %393, %394
  %396 = sext i1 %395 to i32
  %397 = add nsw i32 %54, %396
  %398 = icmp ult i64 %390, %391
  br i1 %398, label %399, label %402

399:                                              ; preds = %387
  %400 = add i64 %388, -1
  tail call fastcc void @pdqsort_loop(ptr noundef %0, i64 noundef %52, i64 noundef %400, i64 noundef %3, ptr noundef %4, i32 noundef %397, i1 noundef zeroext %57)
  %401 = add nuw i64 %389, 1
  br label %405

402:                                              ; preds = %387
  %403 = add nuw i64 %389, 1
  tail call fastcc void @pdqsort_loop(ptr noundef %0, i64 noundef %403, i64 noundef %53, i64 noundef %3, ptr noundef %4, i32 noundef %397, i1 noundef zeroext false)
  %404 = add i64 %388, -1
  br label %405

405:                                              ; preds = %399, %402
  %406 = phi i8 [ 0, %399 ], [ %55, %402 ]
  %407 = phi i64 [ %53, %399 ], [ %404, %402 ]
  %408 = phi i64 [ %401, %399 ], [ %52, %402 ]
  %409 = sub i64 %407, %408
  %410 = add i64 %409, 1
  %411 = icmp ult i64 %410, 25
  br i1 %411, label %20, label %50

412:                                              ; preds = %58, %100, %203, %45, %20, %103
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i32 @compare_int(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) #2 {
  %3 = load i32, ptr %0, align 4, !tbaa !14
  %4 = load i32, ptr %1, align 4, !tbaa !14
  %5 = icmp sgt i32 %3, %4
  %6 = zext i1 %5 to i32
  %7 = icmp slt i32 %3, %4
  %8 = sext i1 %7 to i32
  %9 = add nsw i32 %8, %6
  ret i32 %9
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable
define dso_local i32 @compare_double(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #2 {
  %3 = load double, ptr %0, align 8, !tbaa !18
  %4 = load double, ptr %1, align 8, !tbaa !18
  %5 = fcmp ogt double %3, %4
  %6 = zext i1 %5 to i32
  %7 = fcmp olt double %3, %4
  %8 = sext i1 %7 to i32
  %9 = add nsw i32 %8, %6
  ret i32 %9
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(read, inaccessiblemem: none) uwtable
define dso_local i32 @compare_string(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #3 {
  %3 = load ptr, ptr %0, align 8, !tbaa !20
  %4 = load ptr, ptr %1, align 8, !tbaa !20
  %5 = tail call i32 @strcmp(ptr noundef nonnull dereferenceable(1) %3, ptr noundef nonnull dereferenceable(1) %4) #18
  ret i32 %5
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: read)
declare i32 @strcmp(ptr nocapture noundef, ptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: mustprogress nofree nounwind willreturn memory(read, inaccessiblemem: none) uwtable
define dso_local i32 @compare_string_length(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1) local_unnamed_addr #3 {
  %3 = load ptr, ptr %0, align 8, !tbaa !20
  %4 = load ptr, ptr %1, align 8, !tbaa !20
  %5 = tail call i64 @strlen(ptr noundef nonnull dereferenceable(1) %3) #18
  %6 = tail call i64 @strlen(ptr noundef nonnull dereferenceable(1) %4) #18
  %7 = icmp ult i64 %5, %6
  br i1 %7, label %12, label %8

8:                                                ; preds = %2
  %9 = icmp ugt i64 %5, %6
  br i1 %9, label %12, label %10

10:                                               ; preds = %8
  %11 = tail call i32 @strcmp(ptr noundef nonnull dereferenceable(1) %3, ptr noundef nonnull dereferenceable(1) %4) #18
  br label %12

12:                                               ; preds = %8, %2, %10
  %13 = phi i32 [ %11, %10 ], [ -1, %2 ], [ 1, %8 ]
  ret i32 %13
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: read)
declare i64 @strlen(ptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @get_time_diff(i64 noundef %0, i64 noundef %1) local_unnamed_addr #5 {
  %3 = sub nsw i64 %1, %0
  %4 = sitofp i64 %3 to double
  %5 = fdiv double %4, 1.000000e+06
  ret double %5
}

; Function Attrs: nounwind uwtable
define dso_local void @generate_random_array(ptr nocapture noundef writeonly %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = icmp eq i64 %1, 0
  br i1 %3, label %4, label %5

4:                                                ; preds = %5, %2
  ret void

5:                                                ; preds = %2, %5
  %6 = phi i64 [ %10, %5 ], [ 0, %2 ]
  %7 = tail call i32 @rand() #17
  %8 = srem i32 %7, 10000
  %9 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 %8, ptr %9, align 4, !tbaa !14
  %10 = add nuw i64 %6, 1
  %11 = icmp eq i64 %10, %1
  br i1 %11, label %4, label %5, !llvm.loop !22
}

; Function Attrs: nounwind
declare i32 @rand() local_unnamed_addr #6

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: write) uwtable
define dso_local void @generate_sorted_array(ptr nocapture noundef writeonly %0, i64 noundef %1) local_unnamed_addr #7 {
  %3 = icmp eq i64 %1, 0
  br i1 %3, label %21, label %4

4:                                                ; preds = %2
  %5 = icmp ult i64 %1, 8
  br i1 %5, label %19, label %6

6:                                                ; preds = %4
  %7 = and i64 %1, -8
  br label %8

8:                                                ; preds = %8, %6
  %9 = phi i64 [ 0, %6 ], [ %14, %8 ]
  %10 = phi <4 x i32> [ <i32 0, i32 1, i32 2, i32 3>, %6 ], [ %15, %8 ]
  %11 = add <4 x i32> %10, <i32 4, i32 4, i32 4, i32 4>
  %12 = getelementptr inbounds i32, ptr %0, i64 %9
  %13 = getelementptr inbounds i32, ptr %12, i64 4
  store <4 x i32> %10, ptr %12, align 4, !tbaa !14
  store <4 x i32> %11, ptr %13, align 4, !tbaa !14
  %14 = add nuw i64 %9, 8
  %15 = add <4 x i32> %10, <i32 8, i32 8, i32 8, i32 8>
  %16 = icmp eq i64 %14, %7
  br i1 %16, label %17, label %8, !llvm.loop !23

17:                                               ; preds = %8
  %18 = icmp eq i64 %7, %1
  br i1 %18, label %21, label %19

19:                                               ; preds = %4, %17
  %20 = phi i64 [ 0, %4 ], [ %7, %17 ]
  br label %22

21:                                               ; preds = %22, %17, %2
  ret void

22:                                               ; preds = %19, %22
  %23 = phi i64 [ %26, %22 ], [ %20, %19 ]
  %24 = trunc i64 %23 to i32
  %25 = getelementptr inbounds i32, ptr %0, i64 %23
  store i32 %24, ptr %25, align 4, !tbaa !14
  %26 = add nuw i64 %23, 1
  %27 = icmp eq i64 %26, %1
  br i1 %27, label %21, label %22, !llvm.loop !26
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: write) uwtable
define dso_local void @generate_reverse_sorted_array(ptr nocapture noundef writeonly %0, i64 noundef %1) local_unnamed_addr #7 {
  %3 = icmp eq i64 %1, 0
  br i1 %3, label %28, label %4

4:                                                ; preds = %2
  %5 = icmp ult i64 %1, 8
  br i1 %5, label %26, label %6

6:                                                ; preds = %4
  %7 = and i64 %1, -8
  %8 = insertelement <4 x i64> poison, i64 %1, i64 0
  %9 = shufflevector <4 x i64> %8, <4 x i64> poison, <4 x i32> zeroinitializer
  br label %10

10:                                               ; preds = %10, %6
  %11 = phi i64 [ 0, %6 ], [ %21, %10 ]
  %12 = phi <4 x i64> [ <i64 0, i64 1, i64 2, i64 3>, %6 ], [ %22, %10 ]
  %13 = xor <4 x i64> %12, <i64 -1, i64 -1, i64 -1, i64 -1>
  %14 = add <4 x i64> %9, %13
  %15 = sub <4 x i64> %9, %12
  %16 = trunc <4 x i64> %14 to <4 x i32>
  %17 = trunc <4 x i64> %15 to <4 x i32>
  %18 = add <4 x i32> %17, <i32 -5, i32 -5, i32 -5, i32 -5>
  %19 = getelementptr inbounds i32, ptr %0, i64 %11
  %20 = getelementptr inbounds i32, ptr %19, i64 4
  store <4 x i32> %16, ptr %19, align 4, !tbaa !14
  store <4 x i32> %18, ptr %20, align 4, !tbaa !14
  %21 = add nuw i64 %11, 8
  %22 = add <4 x i64> %12, <i64 8, i64 8, i64 8, i64 8>
  %23 = icmp eq i64 %21, %7
  br i1 %23, label %24, label %10, !llvm.loop !27

24:                                               ; preds = %10
  %25 = icmp eq i64 %7, %1
  br i1 %25, label %28, label %26

26:                                               ; preds = %4, %24
  %27 = phi i64 [ 0, %4 ], [ %7, %24 ]
  br label %29

28:                                               ; preds = %29, %24, %2
  ret void

29:                                               ; preds = %26, %29
  %30 = phi i64 [ %35, %29 ], [ %27, %26 ]
  %31 = xor i64 %30, -1
  %32 = add i64 %31, %1
  %33 = trunc i64 %32 to i32
  %34 = getelementptr inbounds i32, ptr %0, i64 %30
  store i32 %33, ptr %34, align 4, !tbaa !14
  %35 = add nuw i64 %30, 1
  %36 = icmp eq i64 %35, %1
  br i1 %36, label %28, label %29, !llvm.loop !28
}

; Function Attrs: nounwind uwtable
define dso_local void @generate_nearly_sorted_array(ptr nocapture noundef %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = icmp eq i64 %1, 0
  br i1 %3, label %30, label %4

4:                                                ; preds = %2
  %5 = icmp ult i64 %1, 8
  br i1 %5, label %19, label %6

6:                                                ; preds = %4
  %7 = and i64 %1, -8
  br label %8

8:                                                ; preds = %8, %6
  %9 = phi i64 [ 0, %6 ], [ %14, %8 ]
  %10 = phi <4 x i32> [ <i32 0, i32 1, i32 2, i32 3>, %6 ], [ %15, %8 ]
  %11 = add <4 x i32> %10, <i32 4, i32 4, i32 4, i32 4>
  %12 = getelementptr inbounds i32, ptr %0, i64 %9
  %13 = getelementptr inbounds i32, ptr %12, i64 4
  store <4 x i32> %10, ptr %12, align 4, !tbaa !14
  store <4 x i32> %11, ptr %13, align 4, !tbaa !14
  %14 = add nuw i64 %9, 8
  %15 = add <4 x i32> %10, <i32 8, i32 8, i32 8, i32 8>
  %16 = icmp eq i64 %14, %7
  br i1 %16, label %17, label %8, !llvm.loop !29

17:                                               ; preds = %8
  %18 = icmp eq i64 %7, %1
  br i1 %18, label %27, label %19

19:                                               ; preds = %4, %17
  %20 = phi i64 [ 0, %4 ], [ %7, %17 ]
  br label %21

21:                                               ; preds = %19, %21
  %22 = phi i64 [ %25, %21 ], [ %20, %19 ]
  %23 = trunc i64 %22 to i32
  %24 = getelementptr inbounds i32, ptr %0, i64 %22
  store i32 %23, ptr %24, align 4, !tbaa !14
  %25 = add nuw i64 %22, 1
  %26 = icmp eq i64 %25, %1
  br i1 %26, label %27, label %21, !llvm.loop !30

27:                                               ; preds = %21, %17
  %28 = udiv i64 %1, 20
  %29 = icmp ult i64 %1, 20
  br i1 %29, label %30, label %31

30:                                               ; preds = %31, %2, %27
  ret void

31:                                               ; preds = %27, %31
  %32 = phi i64 [ %43, %31 ], [ 0, %27 ]
  %33 = tail call i32 @rand() #17
  %34 = sext i32 %33 to i64
  %35 = urem i64 %34, %1
  %36 = tail call i32 @rand() #17
  %37 = sext i32 %36 to i64
  %38 = urem i64 %37, %1
  %39 = getelementptr inbounds i32, ptr %0, i64 %35
  %40 = load i32, ptr %39, align 4, !tbaa !14
  %41 = getelementptr inbounds i32, ptr %0, i64 %38
  %42 = load i32, ptr %41, align 4, !tbaa !14
  store i32 %42, ptr %39, align 4, !tbaa !14
  store i32 %40, ptr %41, align 4, !tbaa !14
  %43 = add nuw nsw i64 %32, 1
  %44 = icmp eq i64 %43, %28
  br i1 %44, label %30, label %31, !llvm.loop !31
}

; Function Attrs: nounwind uwtable
define dso_local void @generate_duplicate_array(ptr nocapture noundef writeonly %0, i64 noundef %1) local_unnamed_addr #0 {
  %3 = icmp eq i64 %1, 0
  br i1 %3, label %4, label %5

4:                                                ; preds = %5, %2
  ret void

5:                                                ; preds = %2, %5
  %6 = phi i64 [ %13, %5 ], [ 0, %2 ]
  %7 = tail call i32 @rand() #17
  %8 = srem i32 %7, 5
  %9 = sext i32 %8 to i64
  %10 = getelementptr inbounds [5 x i32], ptr @__const.generate_duplicate_array.values, i64 0, i64 %9
  %11 = load i32, ptr %10, align 4, !tbaa !14
  %12 = getelementptr inbounds i32, ptr %0, i64 %6
  store i32 %11, ptr %12, align 4, !tbaa !14
  %13 = add nuw i64 %6, 1
  %14 = icmp eq i64 %13, %1
  br i1 %14, label %4, label %5, !llvm.loop !32
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #8

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: read) uwtable
define dso_local zeroext i1 @is_sorted(ptr nocapture noundef readonly %0, i64 noundef %1) local_unnamed_addr #9 {
  %3 = icmp ult i64 %1, 2
  br i1 %3, label %21, label %4

4:                                                ; preds = %2
  %5 = getelementptr inbounds i32, ptr %0, i64 1
  %6 = load i32, ptr %5, align 4, !tbaa !14
  %7 = load i32, ptr %0, align 4, !tbaa !14
  %8 = icmp slt i32 %6, %7
  br i1 %8, label %21, label %9

9:                                                ; preds = %4, %13
  %10 = phi i64 [ %11, %13 ], [ 1, %4 ]
  %11 = add nuw i64 %10, 1
  %12 = icmp eq i64 %11, %1
  br i1 %12, label %19, label %13, !llvm.loop !33

13:                                               ; preds = %9
  %14 = getelementptr inbounds i32, ptr %0, i64 %11
  %15 = load i32, ptr %14, align 4, !tbaa !14
  %16 = getelementptr i32, ptr %0, i64 %10
  %17 = load i32, ptr %16, align 4, !tbaa !14
  %18 = icmp slt i32 %15, %17
  br i1 %18, label %19, label %9, !llvm.loop !33

19:                                               ; preds = %9, %13
  %20 = icmp uge i64 %11, %1
  br label %21

21:                                               ; preds = %19, %4, %2
  %22 = phi i1 [ true, %2 ], [ false, %4 ], [ %20, %19 ]
  ret i1 %22
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable
define dso_local void @copy_array(ptr nocapture noundef writeonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #10 {
  %4 = shl i64 %2, 2
  tail call void @llvm.memcpy.p0.p0.i64(ptr align 4 %0, ptr align 4 %1, i64 %4, i1 false)
  ret void
}

; Function Attrs: nofree nounwind uwtable
define dso_local void @print_array(ptr nocapture noundef readonly %0, i64 noundef %1) local_unnamed_addr #11 {
  %3 = tail call i32 @putchar(i32 91)
  %4 = icmp eq i64 %1, 0
  br i1 %4, label %7, label %5

5:                                                ; preds = %2
  %6 = add i64 %1, -1
  br label %9

7:                                                ; preds = %17, %2
  %8 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  ret void

9:                                                ; preds = %5, %17
  %10 = phi i64 [ 0, %5 ], [ %18, %17 ]
  %11 = getelementptr inbounds i32, ptr %0, i64 %10
  %12 = load i32, ptr %11, align 4, !tbaa !14
  %13 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %12)
  %14 = icmp ult i64 %10, %6
  br i1 %14, label %15, label %17

15:                                               ; preds = %9
  %16 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %17

17:                                               ; preds = %9, %15
  %18 = add nuw i64 %10, 1
  %19 = icmp eq i64 %18, %1
  br i1 %19, label %7, label %9, !llvm.loop !34
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #12

; Function Attrs: nofree nounwind uwtable
define dso_local void @print_string_array(ptr nocapture noundef readonly %0, i64 noundef %1) local_unnamed_addr #11 {
  %3 = tail call i32 @putchar(i32 91)
  %4 = icmp eq i64 %1, 0
  br i1 %4, label %7, label %5

5:                                                ; preds = %2
  %6 = add i64 %1, -1
  br label %9

7:                                                ; preds = %17, %2
  %8 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  ret void

9:                                                ; preds = %5, %17
  %10 = phi i64 [ 0, %5 ], [ %18, %17 ]
  %11 = getelementptr inbounds ptr, ptr %0, i64 %10
  %12 = load ptr, ptr %11, align 8, !tbaa !20
  %13 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, ptr noundef %12)
  %14 = icmp ult i64 %10, %6
  br i1 %14, label %15, label %17

15:                                               ; preds = %9
  %16 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %17

17:                                               ; preds = %9, %15
  %18 = add nuw i64 %10, 1
  %19 = icmp eq i64 %18, %1
  br i1 %19, label %7, label %9, !llvm.loop !35
}

; Function Attrs: nounwind uwtable
define dso_local noundef i32 @main() local_unnamed_addr #0 {
  %1 = alloca [11 x i32], align 16
  %2 = alloca [6 x double], align 16
  %3 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.41)
  call void @llvm.lifetime.start.p0(i64 44, ptr nonnull %1) #17
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 16 dereferenceable(44) %1, ptr noundef nonnull align 16 dereferenceable(44) @__const.main.arr1, i64 44, i1 false)
  %4 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.6)
  %5 = tail call i32 @putchar(i32 91)
  %6 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 64)
  %7 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %8 = getelementptr inbounds i32, ptr %1, i64 1
  %9 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 34)
  %10 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %11 = getelementptr inbounds i32, ptr %1, i64 2
  %12 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 25)
  %13 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %14 = getelementptr inbounds i32, ptr %1, i64 3
  %15 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 12)
  %16 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %17 = getelementptr inbounds i32, ptr %1, i64 4
  %18 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 22)
  %19 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %20 = getelementptr inbounds i32, ptr %1, i64 5
  %21 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 11)
  %22 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %23 = getelementptr inbounds i32, ptr %1, i64 6
  %24 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 90)
  %25 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %26 = getelementptr inbounds i32, ptr %1, i64 7
  %27 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 88)
  %28 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %29 = getelementptr inbounds i32, ptr %1, i64 8
  %30 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 76)
  %31 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %32 = getelementptr inbounds i32, ptr %1, i64 9
  %33 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 50)
  %34 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %35 = getelementptr inbounds i32, ptr %1, i64 10
  %36 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef 42)
  %37 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  br label %38

38:                                               ; preds = %54, %0
  %39 = phi i64 [ %58, %54 ], [ 1, %0 ]
  %40 = shl nuw nsw i64 %39, 2
  %41 = getelementptr inbounds i8, ptr %1, i64 %40
  %42 = load i32, ptr %41, align 4
  br label %43

43:                                               ; preds = %38, %50
  %44 = phi i64 [ %45, %50 ], [ %39, %38 ]
  %45 = add nsw i64 %44, -1
  %46 = shl i64 %45, 2
  %47 = getelementptr inbounds i8, ptr %1, i64 %46
  %48 = load i32, ptr %47, align 4
  %49 = icmp sgt i32 %48, %42
  br i1 %49, label %50, label %54

50:                                               ; preds = %43
  %51 = shl i64 %44, 2
  %52 = getelementptr inbounds i8, ptr %1, i64 %51
  store i32 %48, ptr %52, align 4
  %53 = icmp eq i64 %45, 0
  br i1 %53, label %54, label %43, !llvm.loop !7

54:                                               ; preds = %43, %50
  %55 = phi i64 [ %44, %43 ], [ 0, %50 ]
  %56 = shl i64 %55, 2
  %57 = getelementptr inbounds i8, ptr %1, i64 %56
  store i32 %42, ptr %57, align 4
  %58 = add nuw nsw i64 %39, 1
  %59 = icmp eq i64 %58, 11
  br i1 %59, label %60, label %38, !llvm.loop !8

60:                                               ; preds = %54
  %61 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.7)
  %62 = tail call i32 @putchar(i32 91)
  %63 = load i32, ptr %1, align 16, !tbaa !14
  %64 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %63)
  %65 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %66 = load i32, ptr %8, align 4, !tbaa !14
  %67 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %66)
  %68 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %69 = load i32, ptr %11, align 8, !tbaa !14
  %70 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %69)
  %71 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %72 = load i32, ptr %14, align 4, !tbaa !14
  %73 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %72)
  %74 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %75 = load i32, ptr %17, align 16, !tbaa !14
  %76 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %75)
  %77 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %78 = load i32, ptr %20, align 4, !tbaa !14
  %79 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %78)
  %80 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %81 = load i32, ptr %23, align 8, !tbaa !14
  %82 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %81)
  %83 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %84 = load i32, ptr %26, align 4, !tbaa !14
  %85 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %84)
  %86 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %87 = load i32, ptr %29, align 16, !tbaa !14
  %88 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %87)
  %89 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %90 = load i32, ptr %32, align 4, !tbaa !14
  %91 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %90)
  %92 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %93 = load i32, ptr %35, align 8, !tbaa !14
  %94 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, i32 noundef %93)
  %95 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  %96 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.42)
  call void @llvm.lifetime.start.p0(i64 48, ptr nonnull %2) #17
  %97 = getelementptr inbounds [6 x double], ptr %2, i64 0, i64 1
  %98 = getelementptr inbounds [6 x double], ptr %2, i64 0, i64 2
  %99 = getelementptr inbounds [6 x double], ptr %2, i64 0, i64 3
  %100 = getelementptr inbounds [6 x double], ptr %2, i64 0, i64 4
  %101 = getelementptr inbounds [6 x double], ptr %2, i64 0, i64 5
  store <2 x double> <double 5.700000e-01, double 2.230000e+00>, ptr %100, align 16
  %102 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.9)
  %103 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 3.140000e+00)
  %104 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %105 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 2.710000e+00)
  %106 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %107 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 1.410000e+00)
  %108 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %109 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 1.730000e+00)
  %110 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %111 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 5.700000e-01)
  %112 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %113 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef 2.230000e+00)
  %114 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  store i64 4609028894647239311, ptr %2, align 16
  store i64 4614253070214989087, ptr %99, align 8
  store i64 4613284796295104430, ptr %98, align 16
  %115 = getelementptr inbounds i8, ptr %2, i64 8
  store i64 4610470046527997870, ptr %115, align 8
  %116 = load i64, ptr %100, align 16
  %117 = bitcast i64 %116 to double
  %118 = fcmp olt double %117, 3.140000e+00
  br i1 %118, label %119, label %129

119:                                              ; preds = %60
  store double 3.140000e+00, ptr %100, align 16
  %120 = load double, ptr %98, align 16
  %121 = fcmp ogt double %120, %117
  br i1 %121, label %122, label %129

122:                                              ; preds = %119
  store double %120, ptr %99, align 8
  %123 = load double, ptr %97, align 8
  %124 = fcmp ogt double %123, %117
  br i1 %124, label %125, label %129

125:                                              ; preds = %122
  store double %123, ptr %98, align 16
  %126 = load double, ptr %2, align 16
  %127 = fcmp ogt double %126, %117
  br i1 %127, label %128, label %129

128:                                              ; preds = %125
  store double %126, ptr %97, align 8
  br label %129

129:                                              ; preds = %128, %125, %122, %119, %60
  %130 = phi i64 [ 32, %60 ], [ 24, %119 ], [ 16, %122 ], [ 8, %125 ], [ 0, %128 ]
  %131 = getelementptr inbounds i8, ptr %2, i64 %130
  store i64 %116, ptr %131, align 8
  %132 = load i64, ptr %101, align 8
  %133 = bitcast i64 %132 to double
  %134 = load double, ptr %100, align 16
  %135 = fcmp ogt double %134, %133
  br i1 %135, label %136, label %149

136:                                              ; preds = %129
  store double %134, ptr %101, align 8
  %137 = load double, ptr %99, align 8
  %138 = fcmp ogt double %137, %133
  br i1 %138, label %139, label %149

139:                                              ; preds = %136
  store double %137, ptr %100, align 16
  %140 = load double, ptr %98, align 16
  %141 = fcmp ogt double %140, %133
  br i1 %141, label %142, label %149

142:                                              ; preds = %139
  store double %140, ptr %99, align 8
  %143 = load double, ptr %97, align 8
  %144 = fcmp ogt double %143, %133
  br i1 %144, label %145, label %149

145:                                              ; preds = %142
  store double %143, ptr %98, align 16
  %146 = load double, ptr %2, align 16
  %147 = fcmp ogt double %146, %133
  br i1 %147, label %148, label %149

148:                                              ; preds = %145
  store double %146, ptr %97, align 8
  br label %149

149:                                              ; preds = %148, %145, %142, %139, %136, %129
  %150 = phi i64 [ 40, %129 ], [ 32, %136 ], [ 24, %139 ], [ 16, %142 ], [ 8, %145 ], [ 0, %148 ]
  %151 = getelementptr inbounds i8, ptr %2, i64 %150
  store i64 %132, ptr %151, align 8
  %152 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.11)
  %153 = load double, ptr %2, align 16, !tbaa !18
  %154 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %153)
  %155 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %156 = load double, ptr %97, align 8, !tbaa !18
  %157 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %156)
  %158 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %159 = load double, ptr %98, align 16, !tbaa !18
  %160 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %159)
  %161 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %162 = load double, ptr %99, align 8, !tbaa !18
  %163 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %162)
  %164 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %165 = load double, ptr %100, align 16, !tbaa !18
  %166 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %165)
  %167 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  %168 = load double, ptr %101, align 8, !tbaa !18
  %169 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.10, double noundef %168)
  %170 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  %171 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.45)
  %172 = tail call noalias dereferenceable_or_null(4000) ptr @malloc(i64 noundef 4000) #16
  br label %210

173:                                              ; preds = %210
  %174 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.46)
  tail call fastcc void @pdqsort_loop(ptr noundef nonnull %172, i64 noundef 0, i64 noundef 999, i64 noundef 4, ptr noundef nonnull @compare_int, i32 noundef 9, i1 noundef zeroext true)
  %175 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.14)
  %176 = load i32, ptr %172, align 4, !tbaa !14
  %177 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %176)
  %178 = getelementptr inbounds i32, ptr %172, i64 1
  %179 = load i32, ptr %178, align 4, !tbaa !14
  %180 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %179)
  %181 = getelementptr inbounds i32, ptr %172, i64 2
  %182 = load i32, ptr %181, align 4, !tbaa !14
  %183 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %182)
  %184 = getelementptr inbounds i32, ptr %172, i64 3
  %185 = load i32, ptr %184, align 4, !tbaa !14
  %186 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %185)
  %187 = getelementptr inbounds i32, ptr %172, i64 4
  %188 = load i32, ptr %187, align 4, !tbaa !14
  %189 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %188)
  %190 = getelementptr inbounds i32, ptr %172, i64 5
  %191 = load i32, ptr %190, align 4, !tbaa !14
  %192 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %191)
  %193 = getelementptr inbounds i32, ptr %172, i64 6
  %194 = load i32, ptr %193, align 4, !tbaa !14
  %195 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %194)
  %196 = getelementptr inbounds i32, ptr %172, i64 7
  %197 = load i32, ptr %196, align 4, !tbaa !14
  %198 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %197)
  %199 = getelementptr inbounds i32, ptr %172, i64 8
  %200 = load i32, ptr %199, align 4, !tbaa !14
  %201 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %200)
  %202 = getelementptr inbounds i32, ptr %172, i64 9
  %203 = load i32, ptr %202, align 4, !tbaa !14
  %204 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.15, i32 noundef %203)
  %205 = tail call i32 @putchar(i32 10)
  tail call void @free(ptr noundef nonnull %172) #17
  %206 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.47)
  %207 = tail call noalias dereferenceable_or_null(160) ptr @malloc(i64 noundef 160) #16
  tail call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(160) %207, ptr noundef nonnull align 16 dereferenceable(160) @__const.main.words, i64 160, i1 false), !tbaa !20
  %208 = tail call i64 @time(ptr noundef null) #17
  %209 = trunc i64 %208 to i32
  tail call void @srand(i32 noundef %209) #17
  br label %275

210:                                              ; preds = %149, %210
  %211 = phi i64 [ 0, %149 ], [ %215, %210 ]
  %212 = tail call i32 @rand() #17
  %213 = srem i32 %212, 1000
  %214 = getelementptr inbounds i32, ptr %172, i64 %211
  store i32 %213, ptr %214, align 4, !tbaa !14
  %215 = add nuw nsw i64 %211, 1
  %216 = icmp eq i64 %215, 1000
  br i1 %216, label %173, label %210, !llvm.loop !36

217:                                              ; preds = %275
  %218 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.6)
  %219 = tail call i32 @putchar(i32 91)
  br label %220

220:                                              ; preds = %228, %217
  %221 = phi i64 [ 0, %217 ], [ %229, %228 ]
  %222 = getelementptr inbounds ptr, ptr %207, i64 %221
  %223 = load ptr, ptr %222, align 8, !tbaa !20
  %224 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, ptr noundef %223)
  %225 = icmp ult i64 %221, 19
  br i1 %225, label %226, label %228

226:                                              ; preds = %220
  %227 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %228

228:                                              ; preds = %226, %220
  %229 = add nuw nsw i64 %221, 1
  %230 = icmp eq i64 %229, 20
  br i1 %230, label %231, label %220, !llvm.loop !35

231:                                              ; preds = %228
  %232 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  br label %233

233:                                              ; preds = %252, %231
  %234 = phi i64 [ %256, %252 ], [ 1, %231 ]
  %235 = shl nuw nsw i64 %234, 3
  %236 = getelementptr inbounds i8, ptr %207, i64 %235
  %237 = load i64, ptr %236, align 1
  %238 = inttoptr i64 %237 to ptr
  br label %239

239:                                              ; preds = %233, %247
  %240 = phi i64 [ %241, %247 ], [ %234, %233 ]
  %241 = add nsw i64 %240, -1
  %242 = shl i64 %241, 3
  %243 = getelementptr inbounds i8, ptr %207, i64 %242
  %244 = load ptr, ptr %243, align 8
  %245 = tail call i32 @strcmp(ptr noundef nonnull dereferenceable(1) %244, ptr noundef nonnull dereferenceable(1) %238) #18
  %246 = icmp sgt i32 %245, 0
  br i1 %246, label %247, label %252

247:                                              ; preds = %239
  %248 = ptrtoint ptr %244 to i64
  %249 = shl i64 %240, 3
  %250 = getelementptr inbounds i8, ptr %207, i64 %249
  store i64 %248, ptr %250, align 1
  %251 = icmp eq i64 %241, 0
  br i1 %251, label %252, label %239, !llvm.loop !7

252:                                              ; preds = %239, %247
  %253 = phi i64 [ %240, %239 ], [ 0, %247 ]
  %254 = shl i64 %253, 3
  %255 = getelementptr inbounds i8, ptr %207, i64 %254
  store i64 %237, ptr %255, align 1
  %256 = add nuw nsw i64 %234, 1
  %257 = icmp eq i64 %256, 20
  br i1 %257, label %258, label %233, !llvm.loop !8

258:                                              ; preds = %252
  %259 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.7)
  %260 = tail call i32 @putchar(i32 91)
  br label %261

261:                                              ; preds = %269, %258
  %262 = phi i64 [ 0, %258 ], [ %270, %269 ]
  %263 = getelementptr inbounds ptr, ptr %207, i64 %262
  %264 = load ptr, ptr %263, align 8, !tbaa !20
  %265 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, ptr noundef %264)
  %266 = icmp ult i64 %262, 19
  br i1 %266, label %267, label %269

267:                                              ; preds = %261
  %268 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %269

269:                                              ; preds = %267, %261
  %270 = add nuw nsw i64 %262, 1
  %271 = icmp eq i64 %270, 20
  br i1 %271, label %272, label %261, !llvm.loop !35

272:                                              ; preds = %269
  %273 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  %274 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.48)
  br label %350

275:                                              ; preds = %173, %275
  %276 = phi i64 [ 19, %173 ], [ %285, %275 ]
  %277 = tail call i32 @rand() #17
  %278 = sext i32 %277 to i64
  %279 = add nuw nsw i64 %276, 1
  %280 = urem i64 %278, %279
  %281 = getelementptr inbounds ptr, ptr %207, i64 %276
  %282 = load ptr, ptr %281, align 8, !tbaa !20
  %283 = getelementptr inbounds ptr, ptr %207, i64 %280
  %284 = load ptr, ptr %283, align 8, !tbaa !20
  store ptr %284, ptr %281, align 8, !tbaa !20
  store ptr %282, ptr %283, align 8, !tbaa !20
  %285 = add nsw i64 %276, -1
  %286 = icmp eq i64 %285, 0
  br i1 %286, label %217, label %275, !llvm.loop !37

287:                                              ; preds = %350
  %288 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.6)
  %289 = tail call i32 @putchar(i32 91)
  br label %290

290:                                              ; preds = %298, %287
  %291 = phi i64 [ 0, %287 ], [ %299, %298 ]
  %292 = getelementptr inbounds ptr, ptr %207, i64 %291
  %293 = load ptr, ptr %292, align 8, !tbaa !20
  %294 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, ptr noundef %293)
  %295 = icmp ult i64 %291, 19
  br i1 %295, label %296, label %298

296:                                              ; preds = %290
  %297 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %298

298:                                              ; preds = %296, %290
  %299 = add nuw nsw i64 %291, 1
  %300 = icmp eq i64 %299, 20
  br i1 %300, label %301, label %290, !llvm.loop !35

301:                                              ; preds = %298
  %302 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  br label %303

303:                                              ; preds = %328, %301
  %304 = phi i64 [ %332, %328 ], [ 1, %301 ]
  %305 = shl nuw nsw i64 %304, 3
  %306 = getelementptr inbounds i8, ptr %207, i64 %305
  %307 = load i64, ptr %306, align 1
  %308 = inttoptr i64 %307 to ptr
  %309 = tail call i64 @strlen(ptr noundef nonnull dereferenceable(1) %308) #18
  br label %310

310:                                              ; preds = %303, %324
  %311 = phi i64 [ %312, %324 ], [ %304, %303 ]
  %312 = add nsw i64 %311, -1
  %313 = shl i64 %312, 3
  %314 = getelementptr inbounds i8, ptr %207, i64 %313
  %315 = load ptr, ptr %314, align 8
  %316 = tail call i64 @strlen(ptr noundef nonnull dereferenceable(1) %315) #18
  %317 = icmp ult i64 %316, %309
  %318 = ptrtoint ptr %315 to i64
  br i1 %317, label %328, label %319

319:                                              ; preds = %310
  %320 = icmp ugt i64 %316, %309
  br i1 %320, label %324, label %321

321:                                              ; preds = %319
  %322 = tail call i32 @strcmp(ptr noundef nonnull dereferenceable(1) %315, ptr noundef nonnull dereferenceable(1) %308) #18
  %323 = icmp sgt i32 %322, 0
  br i1 %323, label %324, label %328

324:                                              ; preds = %319, %321
  %325 = shl i64 %311, 3
  %326 = getelementptr inbounds i8, ptr %207, i64 %325
  store i64 %318, ptr %326, align 1
  %327 = icmp eq i64 %312, 0
  br i1 %327, label %328, label %310, !llvm.loop !7

328:                                              ; preds = %321, %324, %310
  %329 = phi i64 [ %311, %321 ], [ 0, %324 ], [ %311, %310 ]
  %330 = shl i64 %329, 3
  %331 = getelementptr inbounds i8, ptr %207, i64 %330
  store i64 %307, ptr %331, align 1
  %332 = add nuw nsw i64 %304, 1
  %333 = icmp eq i64 %332, 20
  br i1 %333, label %334, label %303, !llvm.loop !8

334:                                              ; preds = %328
  %335 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.39)
  %336 = tail call i32 @putchar(i32 91)
  br label %337

337:                                              ; preds = %345, %334
  %338 = phi i64 [ 0, %334 ], [ %346, %345 ]
  %339 = getelementptr inbounds ptr, ptr %207, i64 %338
  %340 = load ptr, ptr %339, align 8, !tbaa !20
  %341 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.4, ptr noundef %340)
  %342 = icmp ult i64 %338, 19
  br i1 %342, label %343, label %345

343:                                              ; preds = %337
  %344 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.2)
  br label %345

345:                                              ; preds = %343, %337
  %346 = add nuw nsw i64 %338, 1
  %347 = icmp eq i64 %346, 20
  br i1 %347, label %348, label %337, !llvm.loop !35

348:                                              ; preds = %345
  %349 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.44)
  tail call void @free(ptr noundef nonnull %207) #17
  call void @llvm.lifetime.end.p0(i64 48, ptr nonnull %2) #17
  call void @llvm.lifetime.end.p0(i64 44, ptr nonnull %1) #17
  ret i32 0

350:                                              ; preds = %272, %350
  %351 = phi i64 [ 19, %272 ], [ %360, %350 ]
  %352 = tail call i32 @rand() #17
  %353 = sext i32 %352 to i64
  %354 = add nuw nsw i64 %351, 1
  %355 = urem i64 %353, %354
  %356 = getelementptr inbounds ptr, ptr %207, i64 %351
  %357 = load ptr, ptr %356, align 8, !tbaa !20
  %358 = getelementptr inbounds ptr, ptr %207, i64 %355
  %359 = load ptr, ptr %358, align 8, !tbaa !20
  store ptr %359, ptr %356, align 8, !tbaa !20
  store ptr %357, ptr %358, align 8, !tbaa !20
  %360 = add nsw i64 %351, -1
  %361 = icmp eq i64 %360, 0
  br i1 %361, label %287, label %350, !llvm.loop !38
}

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #13

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #14

; Function Attrs: nounwind
declare void @srand(i32 noundef) local_unnamed_addr #6

; Function Attrs: nounwind
declare i64 @time(ptr noundef) local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare noundef i32 @putchar(i32 noundef) local_unnamed_addr #15

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #15

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { mustprogress nofree nounwind willreturn memory(read, inaccessiblemem: none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { mustprogress nofree nounwind willreturn memory(argmem: read) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #7 = { nofree norecurse nosync nounwind memory(argmem: write) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #8 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #9 = { nofree norecurse nosync nounwind memory(argmem: read) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #10 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #11 = { nofree nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #12 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #13 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #14 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #15 = { nofree nounwind }
attributes #16 = { nounwind allocsize(0) }
attributes #17 = { nounwind }
attributes #18 = { nounwind willreturn memory(read) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 18.1.8"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !6}
!11 = distinct !{!11, !6}
!12 = distinct !{!12, !6}
!13 = distinct !{!13, !6}
!14 = !{!15, !15, i64 0}
!15 = !{!"int", !16, i64 0}
!16 = !{!"omnipotent char", !17, i64 0}
!17 = !{!"Simple C/C++ TBAA"}
!18 = !{!19, !19, i64 0}
!19 = !{!"double", !16, i64 0}
!20 = !{!21, !21, i64 0}
!21 = !{!"any pointer", !16, i64 0}
!22 = distinct !{!22, !6}
!23 = distinct !{!23, !6, !24, !25}
!24 = !{!"llvm.loop.isvectorized", i32 1}
!25 = !{!"llvm.loop.unroll.runtime.disable"}
!26 = distinct !{!26, !6, !25, !24}
!27 = distinct !{!27, !6, !24, !25}
!28 = distinct !{!28, !6, !25, !24}
!29 = distinct !{!29, !6, !24, !25}
!30 = distinct !{!30, !6, !25, !24}
!31 = distinct !{!31, !6}
!32 = distinct !{!32, !6}
!33 = distinct !{!33, !6}
!34 = distinct !{!34, !6}
!35 = distinct !{!35, !6}
!36 = distinct !{!36, !6}
!37 = distinct !{!37, !6}
!38 = distinct !{!38, !6}

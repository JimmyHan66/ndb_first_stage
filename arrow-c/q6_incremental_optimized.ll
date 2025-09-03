; ModuleID = 'q6_incremental_optimized.c'
source_filename = "q6_incremental_optimized.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.ArrowArray = type { i64, i64, i64, i64, i64, ptr, ptr, ptr, ptr, ptr }

@.str.1 = private unnamed_addr constant [21 x i8] c"  sum_revenue: %.2f\0A\00", align 1
@str = private unnamed_addr constant [30 x i8] c"\0A=== Q6 Optimized Results ===\00", align 1
@str.3 = private unnamed_addr constant [30 x i8] c"=============================\00", align 1

; Function Attrs: nounwind uwtable
define dso_local noalias noundef ptr @q6_agg_init_optimized() local_unnamed_addr #0 {
  %1 = tail call noalias dereferenceable_or_null(8) ptr @malloc(i64 noundef 8) #6
  %2 = icmp eq ptr %1, null
  br i1 %2, label %5, label %3

3:                                                ; preds = %0
  %4 = tail call ptr @avx2_double_sum_create(i32 noundef 512) #7
  store ptr %4, ptr %1, align 8, !tbaa !5
  br label %5

5:                                                ; preds = %3, %0
  ret ptr %1
}

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #1

declare ptr @avx2_double_sum_create(i32 noundef) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_process_batch_optimized(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, ptr nocapture noundef readonly %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = icmp sgt i32 %3, 0
  br i1 %5, label %6, label %9

6:                                                ; preds = %4
  %7 = getelementptr inbounds %struct.ArrowArray, ptr %1, i64 0, i32 6
  %8 = zext nneg i32 %3 to i64
  br label %10

9:                                                ; preds = %196, %4
  ret void

10:                                               ; preds = %6, %196
  %11 = phi i64 [ 0, %6 ], [ %200, %196 ]
  %12 = getelementptr inbounds i32, ptr %2, i64 %11
  %13 = load i32, ptr %12, align 4, !tbaa !10
  %14 = sext i32 %13 to i64
  %15 = load ptr, ptr %7, align 8, !tbaa !12
  %16 = getelementptr inbounds ptr, ptr %15, i64 1
  %17 = load ptr, ptr %16, align 8, !tbaa !15
  %18 = getelementptr inbounds %struct.ArrowArray, ptr %17, i64 0, i32 5
  %19 = load ptr, ptr %18, align 8, !tbaa !16
  %20 = getelementptr inbounds ptr, ptr %19, i64 1
  %21 = load ptr, ptr %20, align 8, !tbaa !15
  %22 = icmp eq ptr %21, null
  br i1 %22, label %105, label %23

23:                                               ; preds = %10
  %24 = shl nsw i64 %14, 4
  %25 = getelementptr inbounds i8, ptr %21, i64 %24
  %26 = load i8, ptr %25, align 1, !tbaa !17
  %27 = zext i8 %26 to i128
  %28 = getelementptr inbounds i8, ptr %25, i64 1
  %29 = load i8, ptr %28, align 1, !tbaa !17
  %30 = zext i8 %29 to i128
  %31 = shl nuw nsw i128 %30, 8
  %32 = or disjoint i128 %31, %27
  %33 = getelementptr inbounds i8, ptr %25, i64 2
  %34 = load i8, ptr %33, align 1, !tbaa !17
  %35 = zext i8 %34 to i128
  %36 = shl nuw nsw i128 %35, 16
  %37 = or disjoint i128 %36, %32
  %38 = getelementptr inbounds i8, ptr %25, i64 3
  %39 = load i8, ptr %38, align 1, !tbaa !17
  %40 = zext i8 %39 to i128
  %41 = shl nuw nsw i128 %40, 24
  %42 = or disjoint i128 %41, %37
  %43 = getelementptr inbounds i8, ptr %25, i64 4
  %44 = load i8, ptr %43, align 1, !tbaa !17
  %45 = zext i8 %44 to i128
  %46 = shl nuw nsw i128 %45, 32
  %47 = or disjoint i128 %46, %42
  %48 = getelementptr inbounds i8, ptr %25, i64 5
  %49 = load i8, ptr %48, align 1, !tbaa !17
  %50 = zext i8 %49 to i128
  %51 = shl nuw nsw i128 %50, 40
  %52 = or i128 %51, %47
  %53 = getelementptr inbounds i8, ptr %25, i64 6
  %54 = load i8, ptr %53, align 1, !tbaa !17
  %55 = zext i8 %54 to i128
  %56 = shl nuw nsw i128 %55, 48
  %57 = or i128 %56, %52
  %58 = getelementptr inbounds i8, ptr %25, i64 7
  %59 = load i8, ptr %58, align 1, !tbaa !17
  %60 = zext i8 %59 to i128
  %61 = shl nuw nsw i128 %60, 56
  %62 = or i128 %61, %57
  %63 = getelementptr inbounds i8, ptr %25, i64 8
  %64 = load i8, ptr %63, align 1, !tbaa !17
  %65 = zext i8 %64 to i128
  %66 = shl nuw nsw i128 %65, 64
  %67 = or i128 %66, %62
  %68 = getelementptr inbounds i8, ptr %25, i64 9
  %69 = load i8, ptr %68, align 1, !tbaa !17
  %70 = zext i8 %69 to i128
  %71 = shl nuw nsw i128 %70, 72
  %72 = or i128 %71, %67
  %73 = getelementptr inbounds i8, ptr %25, i64 10
  %74 = load i8, ptr %73, align 1, !tbaa !17
  %75 = zext i8 %74 to i128
  %76 = shl nuw nsw i128 %75, 80
  %77 = or i128 %76, %72
  %78 = getelementptr inbounds i8, ptr %25, i64 11
  %79 = load i8, ptr %78, align 1, !tbaa !17
  %80 = zext i8 %79 to i128
  %81 = shl nuw nsw i128 %80, 88
  %82 = or i128 %81, %77
  %83 = getelementptr inbounds i8, ptr %25, i64 12
  %84 = load i8, ptr %83, align 1, !tbaa !17
  %85 = zext i8 %84 to i128
  %86 = shl nuw nsw i128 %85, 96
  %87 = or i128 %86, %82
  %88 = getelementptr inbounds i8, ptr %25, i64 13
  %89 = load i8, ptr %88, align 1, !tbaa !17
  %90 = zext i8 %89 to i128
  %91 = shl nuw nsw i128 %90, 104
  %92 = or i128 %91, %87
  %93 = getelementptr inbounds i8, ptr %25, i64 14
  %94 = load i8, ptr %93, align 1, !tbaa !17
  %95 = zext i8 %94 to i128
  %96 = shl nuw nsw i128 %95, 112
  %97 = or i128 %96, %92
  %98 = getelementptr inbounds i8, ptr %25, i64 15
  %99 = load i8, ptr %98, align 1, !tbaa !17
  %100 = zext i8 %99 to i128
  %101 = shl nuw i128 %100, 120
  %102 = or i128 %101, %97
  %103 = sitofp i128 %102 to double
  %104 = fdiv double %103, 1.000000e+02
  br label %105

105:                                              ; preds = %23, %10
  %106 = phi double [ %104, %23 ], [ 0.000000e+00, %10 ]
  %107 = getelementptr inbounds ptr, ptr %15, i64 2
  %108 = load ptr, ptr %107, align 8, !tbaa !15
  %109 = getelementptr inbounds %struct.ArrowArray, ptr %108, i64 0, i32 5
  %110 = load ptr, ptr %109, align 8, !tbaa !16
  %111 = getelementptr inbounds ptr, ptr %110, i64 1
  %112 = load ptr, ptr %111, align 8, !tbaa !15
  %113 = icmp eq ptr %112, null
  br i1 %113, label %196, label %114

114:                                              ; preds = %105
  %115 = shl nsw i64 %14, 4
  %116 = getelementptr inbounds i8, ptr %112, i64 %115
  %117 = load i8, ptr %116, align 1, !tbaa !17
  %118 = zext i8 %117 to i128
  %119 = getelementptr inbounds i8, ptr %116, i64 1
  %120 = load i8, ptr %119, align 1, !tbaa !17
  %121 = zext i8 %120 to i128
  %122 = shl nuw nsw i128 %121, 8
  %123 = or disjoint i128 %122, %118
  %124 = getelementptr inbounds i8, ptr %116, i64 2
  %125 = load i8, ptr %124, align 1, !tbaa !17
  %126 = zext i8 %125 to i128
  %127 = shl nuw nsw i128 %126, 16
  %128 = or disjoint i128 %127, %123
  %129 = getelementptr inbounds i8, ptr %116, i64 3
  %130 = load i8, ptr %129, align 1, !tbaa !17
  %131 = zext i8 %130 to i128
  %132 = shl nuw nsw i128 %131, 24
  %133 = or disjoint i128 %132, %128
  %134 = getelementptr inbounds i8, ptr %116, i64 4
  %135 = load i8, ptr %134, align 1, !tbaa !17
  %136 = zext i8 %135 to i128
  %137 = shl nuw nsw i128 %136, 32
  %138 = or disjoint i128 %137, %133
  %139 = getelementptr inbounds i8, ptr %116, i64 5
  %140 = load i8, ptr %139, align 1, !tbaa !17
  %141 = zext i8 %140 to i128
  %142 = shl nuw nsw i128 %141, 40
  %143 = or i128 %142, %138
  %144 = getelementptr inbounds i8, ptr %116, i64 6
  %145 = load i8, ptr %144, align 1, !tbaa !17
  %146 = zext i8 %145 to i128
  %147 = shl nuw nsw i128 %146, 48
  %148 = or i128 %147, %143
  %149 = getelementptr inbounds i8, ptr %116, i64 7
  %150 = load i8, ptr %149, align 1, !tbaa !17
  %151 = zext i8 %150 to i128
  %152 = shl nuw nsw i128 %151, 56
  %153 = or i128 %152, %148
  %154 = getelementptr inbounds i8, ptr %116, i64 8
  %155 = load i8, ptr %154, align 1, !tbaa !17
  %156 = zext i8 %155 to i128
  %157 = shl nuw nsw i128 %156, 64
  %158 = or i128 %157, %153
  %159 = getelementptr inbounds i8, ptr %116, i64 9
  %160 = load i8, ptr %159, align 1, !tbaa !17
  %161 = zext i8 %160 to i128
  %162 = shl nuw nsw i128 %161, 72
  %163 = or i128 %162, %158
  %164 = getelementptr inbounds i8, ptr %116, i64 10
  %165 = load i8, ptr %164, align 1, !tbaa !17
  %166 = zext i8 %165 to i128
  %167 = shl nuw nsw i128 %166, 80
  %168 = or i128 %167, %163
  %169 = getelementptr inbounds i8, ptr %116, i64 11
  %170 = load i8, ptr %169, align 1, !tbaa !17
  %171 = zext i8 %170 to i128
  %172 = shl nuw nsw i128 %171, 88
  %173 = or i128 %172, %168
  %174 = getelementptr inbounds i8, ptr %116, i64 12
  %175 = load i8, ptr %174, align 1, !tbaa !17
  %176 = zext i8 %175 to i128
  %177 = shl nuw nsw i128 %176, 96
  %178 = or i128 %177, %173
  %179 = getelementptr inbounds i8, ptr %116, i64 13
  %180 = load i8, ptr %179, align 1, !tbaa !17
  %181 = zext i8 %180 to i128
  %182 = shl nuw nsw i128 %181, 104
  %183 = or i128 %182, %178
  %184 = getelementptr inbounds i8, ptr %116, i64 14
  %185 = load i8, ptr %184, align 1, !tbaa !17
  %186 = zext i8 %185 to i128
  %187 = shl nuw nsw i128 %186, 112
  %188 = or i128 %187, %183
  %189 = getelementptr inbounds i8, ptr %116, i64 15
  %190 = load i8, ptr %189, align 1, !tbaa !17
  %191 = zext i8 %190 to i128
  %192 = shl nuw i128 %191, 120
  %193 = or i128 %192, %188
  %194 = sitofp i128 %193 to double
  %195 = fdiv double %194, 1.000000e+02
  br label %196

196:                                              ; preds = %114, %105
  %197 = phi double [ %195, %114 ], [ 0.000000e+00, %105 ]
  %198 = load ptr, ptr %0, align 8, !tbaa !5
  %199 = fmul double %106, %197
  tail call void @avx2_double_sum_add(ptr noundef %198, double noundef %199) #7
  %200 = add nuw nsw i64 %11, 1
  %201 = icmp eq i64 %200, %8
  br i1 %201, label %9, label %10, !llvm.loop !18
}

declare void @avx2_double_sum_add(ptr noundef, double noundef) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_finalize_optimized(ptr nocapture noundef readonly %0) local_unnamed_addr #0 {
  %2 = load ptr, ptr %0, align 8, !tbaa !5
  %3 = tail call double @avx2_double_sum_get_result(ptr noundef %2) #7
  %4 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)
  %5 = tail call i32 (ptr, ...) @printf(ptr noundef nonnull dereferenceable(1) @.str.1, double noundef %3)
  %6 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str.3)
  ret void
}

declare double @avx2_double_sum_get_result(ptr noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_destroy_optimized(ptr noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq ptr %0, null
  br i1 %2, label %8, label %3

3:                                                ; preds = %1
  %4 = load ptr, ptr %0, align 8, !tbaa !5
  %5 = icmp eq ptr %4, null
  br i1 %5, label %7, label %6

6:                                                ; preds = %3
  tail call void @avx2_double_sum_destroy(ptr noundef nonnull %4) #7
  br label %7

7:                                                ; preds = %6, %3
  tail call void @free(ptr noundef nonnull %0) #7
  br label %8

8:                                                ; preds = %7, %1
  ret void
}

declare void @avx2_double_sum_destroy(ptr noundef) local_unnamed_addr #2

; Function Attrs: mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite)
declare void @free(ptr allocptr nocapture noundef) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #5

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #1 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #3 = { nofree nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #4 = { mustprogress nounwind willreturn allockind("free") memory(argmem: readwrite, inaccessiblemem: readwrite) "alloc-family"="malloc" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+avx,+avx2,+cmov,+crc32,+cx8,+fxsr,+mmx,+popcnt,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+ssse3,+x87,+xsave" "tune-cpu"="generic" }
attributes #5 = { nofree nounwind }
attributes #6 = { nounwind allocsize(0) }
attributes #7 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Homebrew clang version 18.1.8"}
!5 = !{!6, !7, i64 0}
!6 = !{!"", !7, i64 0}
!7 = !{!"any pointer", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C/C++ TBAA"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !8, i64 0}
!12 = !{!13, !7, i64 48}
!13 = !{!"ArrowArray", !14, i64 0, !14, i64 8, !14, i64 16, !14, i64 24, !14, i64 32, !7, i64 40, !7, i64 48, !7, i64 56, !7, i64 64, !7, i64 72}
!14 = !{!"long", !8, i64 0}
!15 = !{!7, !7, i64 0}
!16 = !{!13, !7, i64 40}
!17 = !{!8, !8, i64 0}
!18 = distinct !{!18, !19}
!19 = !{!"llvm.loop.mustprogress"}

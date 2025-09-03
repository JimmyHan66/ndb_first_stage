; ModuleID = 'q6_incremental.c'
source_filename = "q6_incremental.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Q6AggregationState = type { %struct.AVX2DoubleSumBuffer* }
%struct.AVX2DoubleSumBuffer = type opaque
%struct.AVX2DoubleSumBuffer.0 = type { double*, i32, i32 }
%struct.ArrowArray = type { i64, i64, i64, i64, i64, i8**, %struct.ArrowArray**, %struct.ArrowArray*, void (%struct.ArrowArray*)*, i8* }

@.str.1 = private unnamed_addr constant [21 x i8] c"  sum_revenue: %.2f\0A\00", align 1
@str = private unnamed_addr constant [23 x i8] c"\0A=====================\00", align 1
@str.3 = private unnamed_addr constant [22 x i8] c"=====================\00", align 1

; Function Attrs: nounwind uwtable
define dso_local noalias %struct.Q6AggregationState* @q6_agg_init() local_unnamed_addr #0 {
  %1 = tail call noalias dereferenceable_or_null(8) i8* @malloc(i64 noundef 8) #6
  %2 = icmp eq i8* %1, null
  br i1 %2, label %6, label %3

3:                                                ; preds = %0
  %4 = tail call %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef 512) #6
  %5 = bitcast i8* %1 to %struct.AVX2DoubleSumBuffer.0**
  store %struct.AVX2DoubleSumBuffer.0* %4, %struct.AVX2DoubleSumBuffer.0** %5, align 8, !tbaa !5
  br label %6

6:                                                ; preds = %3, %0
  %7 = bitcast i8* %1 to %struct.Q6AggregationState*
  ret %struct.Q6AggregationState* %7
}

; Function Attrs: inaccessiblememonly mustprogress nofree nounwind willreturn
declare noalias noundef i8* @malloc(i64 noundef) local_unnamed_addr #1

declare %struct.AVX2DoubleSumBuffer.0* @avx2_double_sum_create(i32 noundef) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_process_batch(%struct.Q6AggregationState* nocapture noundef readonly %0, %struct.ArrowArray* nocapture noundef readonly %1, i32* nocapture noundef readonly %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = icmp sgt i32 %3, 0
  br i1 %5, label %6, label %10

6:                                                ; preds = %4
  %7 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %1, i64 0, i32 6
  %8 = bitcast %struct.Q6AggregationState* %0 to %struct.AVX2DoubleSumBuffer.0**
  %9 = zext i32 %3 to i64
  br label %11

10:                                               ; preds = %197, %4
  ret void

11:                                               ; preds = %6, %197
  %12 = phi i64 [ 0, %6 ], [ %201, %197 ]
  %13 = getelementptr inbounds i32, i32* %2, i64 %12
  %14 = load i32, i32* %13, align 4, !tbaa !10
  %15 = sext i32 %14 to i64
  %16 = load %struct.ArrowArray**, %struct.ArrowArray*** %7, align 8, !tbaa !12
  %17 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %16, i64 3
  %18 = load %struct.ArrowArray*, %struct.ArrowArray** %17, align 8, !tbaa !15
  %19 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %18, i64 0, i32 5
  %20 = load i8**, i8*** %19, align 8, !tbaa !16
  %21 = getelementptr inbounds i8*, i8** %20, i64 1
  %22 = load i8*, i8** %21, align 8, !tbaa !15
  %23 = icmp eq i8* %22, null
  br i1 %23, label %106, label %24

24:                                               ; preds = %11
  %25 = shl nsw i64 %15, 4
  %26 = getelementptr inbounds i8, i8* %22, i64 %25
  %27 = load i8, i8* %26, align 1, !tbaa !17
  %28 = zext i8 %27 to i128
  %29 = getelementptr inbounds i8, i8* %26, i64 1
  %30 = load i8, i8* %29, align 1, !tbaa !17
  %31 = zext i8 %30 to i128
  %32 = shl nuw nsw i128 %31, 8
  %33 = or i128 %32, %28
  %34 = getelementptr inbounds i8, i8* %26, i64 2
  %35 = load i8, i8* %34, align 1, !tbaa !17
  %36 = zext i8 %35 to i128
  %37 = shl nuw nsw i128 %36, 16
  %38 = or i128 %37, %33
  %39 = getelementptr inbounds i8, i8* %26, i64 3
  %40 = load i8, i8* %39, align 1, !tbaa !17
  %41 = zext i8 %40 to i128
  %42 = shl nuw nsw i128 %41, 24
  %43 = or i128 %42, %38
  %44 = getelementptr inbounds i8, i8* %26, i64 4
  %45 = load i8, i8* %44, align 1, !tbaa !17
  %46 = zext i8 %45 to i128
  %47 = shl nuw nsw i128 %46, 32
  %48 = or i128 %47, %43
  %49 = getelementptr inbounds i8, i8* %26, i64 5
  %50 = load i8, i8* %49, align 1, !tbaa !17
  %51 = zext i8 %50 to i128
  %52 = shl nuw nsw i128 %51, 40
  %53 = or i128 %52, %48
  %54 = getelementptr inbounds i8, i8* %26, i64 6
  %55 = load i8, i8* %54, align 1, !tbaa !17
  %56 = zext i8 %55 to i128
  %57 = shl nuw nsw i128 %56, 48
  %58 = or i128 %57, %53
  %59 = getelementptr inbounds i8, i8* %26, i64 7
  %60 = load i8, i8* %59, align 1, !tbaa !17
  %61 = zext i8 %60 to i128
  %62 = shl nuw nsw i128 %61, 56
  %63 = or i128 %62, %58
  %64 = getelementptr inbounds i8, i8* %26, i64 8
  %65 = load i8, i8* %64, align 1, !tbaa !17
  %66 = zext i8 %65 to i128
  %67 = shl nuw nsw i128 %66, 64
  %68 = or i128 %67, %63
  %69 = getelementptr inbounds i8, i8* %26, i64 9
  %70 = load i8, i8* %69, align 1, !tbaa !17
  %71 = zext i8 %70 to i128
  %72 = shl nuw nsw i128 %71, 72
  %73 = or i128 %72, %68
  %74 = getelementptr inbounds i8, i8* %26, i64 10
  %75 = load i8, i8* %74, align 1, !tbaa !17
  %76 = zext i8 %75 to i128
  %77 = shl nuw nsw i128 %76, 80
  %78 = or i128 %77, %73
  %79 = getelementptr inbounds i8, i8* %26, i64 11
  %80 = load i8, i8* %79, align 1, !tbaa !17
  %81 = zext i8 %80 to i128
  %82 = shl nuw nsw i128 %81, 88
  %83 = or i128 %82, %78
  %84 = getelementptr inbounds i8, i8* %26, i64 12
  %85 = load i8, i8* %84, align 1, !tbaa !17
  %86 = zext i8 %85 to i128
  %87 = shl nuw nsw i128 %86, 96
  %88 = or i128 %87, %83
  %89 = getelementptr inbounds i8, i8* %26, i64 13
  %90 = load i8, i8* %89, align 1, !tbaa !17
  %91 = zext i8 %90 to i128
  %92 = shl nuw nsw i128 %91, 104
  %93 = or i128 %92, %88
  %94 = getelementptr inbounds i8, i8* %26, i64 14
  %95 = load i8, i8* %94, align 1, !tbaa !17
  %96 = zext i8 %95 to i128
  %97 = shl nuw nsw i128 %96, 112
  %98 = or i128 %97, %93
  %99 = getelementptr inbounds i8, i8* %26, i64 15
  %100 = load i8, i8* %99, align 1, !tbaa !17
  %101 = zext i8 %100 to i128
  %102 = shl nuw i128 %101, 120
  %103 = or i128 %102, %98
  %104 = sitofp i128 %103 to double
  %105 = fdiv double %104, 1.000000e+02
  br label %106

106:                                              ; preds = %24, %11
  %107 = phi double [ %105, %24 ], [ 0.000000e+00, %11 ]
  %108 = getelementptr inbounds %struct.ArrowArray*, %struct.ArrowArray** %16, i64 2
  %109 = load %struct.ArrowArray*, %struct.ArrowArray** %108, align 8, !tbaa !15
  %110 = getelementptr inbounds %struct.ArrowArray, %struct.ArrowArray* %109, i64 0, i32 5
  %111 = load i8**, i8*** %110, align 8, !tbaa !16
  %112 = getelementptr inbounds i8*, i8** %111, i64 1
  %113 = load i8*, i8** %112, align 8, !tbaa !15
  %114 = icmp eq i8* %113, null
  br i1 %114, label %197, label %115

115:                                              ; preds = %106
  %116 = shl nsw i64 %15, 4
  %117 = getelementptr inbounds i8, i8* %113, i64 %116
  %118 = load i8, i8* %117, align 1, !tbaa !17
  %119 = zext i8 %118 to i128
  %120 = getelementptr inbounds i8, i8* %117, i64 1
  %121 = load i8, i8* %120, align 1, !tbaa !17
  %122 = zext i8 %121 to i128
  %123 = shl nuw nsw i128 %122, 8
  %124 = or i128 %123, %119
  %125 = getelementptr inbounds i8, i8* %117, i64 2
  %126 = load i8, i8* %125, align 1, !tbaa !17
  %127 = zext i8 %126 to i128
  %128 = shl nuw nsw i128 %127, 16
  %129 = or i128 %128, %124
  %130 = getelementptr inbounds i8, i8* %117, i64 3
  %131 = load i8, i8* %130, align 1, !tbaa !17
  %132 = zext i8 %131 to i128
  %133 = shl nuw nsw i128 %132, 24
  %134 = or i128 %133, %129
  %135 = getelementptr inbounds i8, i8* %117, i64 4
  %136 = load i8, i8* %135, align 1, !tbaa !17
  %137 = zext i8 %136 to i128
  %138 = shl nuw nsw i128 %137, 32
  %139 = or i128 %138, %134
  %140 = getelementptr inbounds i8, i8* %117, i64 5
  %141 = load i8, i8* %140, align 1, !tbaa !17
  %142 = zext i8 %141 to i128
  %143 = shl nuw nsw i128 %142, 40
  %144 = or i128 %143, %139
  %145 = getelementptr inbounds i8, i8* %117, i64 6
  %146 = load i8, i8* %145, align 1, !tbaa !17
  %147 = zext i8 %146 to i128
  %148 = shl nuw nsw i128 %147, 48
  %149 = or i128 %148, %144
  %150 = getelementptr inbounds i8, i8* %117, i64 7
  %151 = load i8, i8* %150, align 1, !tbaa !17
  %152 = zext i8 %151 to i128
  %153 = shl nuw nsw i128 %152, 56
  %154 = or i128 %153, %149
  %155 = getelementptr inbounds i8, i8* %117, i64 8
  %156 = load i8, i8* %155, align 1, !tbaa !17
  %157 = zext i8 %156 to i128
  %158 = shl nuw nsw i128 %157, 64
  %159 = or i128 %158, %154
  %160 = getelementptr inbounds i8, i8* %117, i64 9
  %161 = load i8, i8* %160, align 1, !tbaa !17
  %162 = zext i8 %161 to i128
  %163 = shl nuw nsw i128 %162, 72
  %164 = or i128 %163, %159
  %165 = getelementptr inbounds i8, i8* %117, i64 10
  %166 = load i8, i8* %165, align 1, !tbaa !17
  %167 = zext i8 %166 to i128
  %168 = shl nuw nsw i128 %167, 80
  %169 = or i128 %168, %164
  %170 = getelementptr inbounds i8, i8* %117, i64 11
  %171 = load i8, i8* %170, align 1, !tbaa !17
  %172 = zext i8 %171 to i128
  %173 = shl nuw nsw i128 %172, 88
  %174 = or i128 %173, %169
  %175 = getelementptr inbounds i8, i8* %117, i64 12
  %176 = load i8, i8* %175, align 1, !tbaa !17
  %177 = zext i8 %176 to i128
  %178 = shl nuw nsw i128 %177, 96
  %179 = or i128 %178, %174
  %180 = getelementptr inbounds i8, i8* %117, i64 13
  %181 = load i8, i8* %180, align 1, !tbaa !17
  %182 = zext i8 %181 to i128
  %183 = shl nuw nsw i128 %182, 104
  %184 = or i128 %183, %179
  %185 = getelementptr inbounds i8, i8* %117, i64 14
  %186 = load i8, i8* %185, align 1, !tbaa !17
  %187 = zext i8 %186 to i128
  %188 = shl nuw nsw i128 %187, 112
  %189 = or i128 %188, %184
  %190 = getelementptr inbounds i8, i8* %117, i64 15
  %191 = load i8, i8* %190, align 1, !tbaa !17
  %192 = zext i8 %191 to i128
  %193 = shl nuw i128 %192, 120
  %194 = or i128 %193, %189
  %195 = sitofp i128 %194 to double
  %196 = fdiv double %195, 1.000000e+02
  br label %197

197:                                              ; preds = %115, %106
  %198 = phi double [ %196, %115 ], [ 0.000000e+00, %106 ]
  %199 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %8, align 8, !tbaa !5
  %200 = fmul double %107, %198
  tail call void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef %199, double noundef %200) #6
  %201 = add nuw nsw i64 %12, 1
  %202 = icmp eq i64 %201, %9
  br i1 %202, label %10, label %11, !llvm.loop !18
}

declare void @avx2_double_sum_add(%struct.AVX2DoubleSumBuffer.0* noundef, double noundef) local_unnamed_addr #2

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_finalize(%struct.Q6AggregationState* nocapture noundef readonly %0) local_unnamed_addr #0 {
  %2 = bitcast %struct.Q6AggregationState* %0 to %struct.AVX2DoubleSumBuffer.0**
  %3 = load %struct.AVX2DoubleSumBuffer.0*, %struct.AVX2DoubleSumBuffer.0** %2, align 8, !tbaa !5
  %4 = tail call double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef %3) #6
  %5 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([23 x i8], [23 x i8]* @str, i64 0, i64 0))
  %6 = tail call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), double noundef %4)
  %7 = tail call i32 @puts(i8* nonnull dereferenceable(1) getelementptr inbounds ([22 x i8], [22 x i8]* @str.3, i64 0, i64 0))
  ret void
}

declare double @avx2_double_sum_get_result(%struct.AVX2DoubleSumBuffer.0* noundef) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #3

; Function Attrs: nounwind uwtable
define dso_local void @q6_agg_destroy(%struct.Q6AggregationState* noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq %struct.Q6AggregationState* %0, null
  br i1 %2, label %11, label %3

3:                                                ; preds = %1
  %4 = getelementptr inbounds %struct.Q6AggregationState, %struct.Q6AggregationState* %0, i64 0, i32 0
  %5 = load %struct.AVX2DoubleSumBuffer*, %struct.AVX2DoubleSumBuffer** %4, align 8, !tbaa !5
  %6 = icmp eq %struct.AVX2DoubleSumBuffer* %5, null
  br i1 %6, label %9, label %7

7:                                                ; preds = %3
  %8 = bitcast %struct.AVX2DoubleSumBuffer* %5 to %struct.AVX2DoubleSumBuffer.0*
  tail call void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef nonnull %8) #6
  br label %9

9:                                                ; preds = %7, %3
  %10 = bitcast %struct.Q6AggregationState* %0 to i8*
  tail call void @free(i8* noundef %10) #6
  br label %11

11:                                               ; preds = %9, %1
  ret void
}

declare void @avx2_double_sum_destroy(%struct.AVX2DoubleSumBuffer.0* noundef) local_unnamed_addr #2

; Function Attrs: inaccessiblemem_or_argmemonly mustprogress nounwind willreturn
declare void @free(i8* nocapture noundef) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare noundef i32 @puts(i8* nocapture noundef readonly) local_unnamed_addr #5

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { inaccessiblememonly mustprogress nofree nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { inaccessiblemem_or_argmemonly mustprogress nounwind willreturn "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #5 = { nofree nounwind }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
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

; ModuleID = 'q1_batch_driver.c'
source_filename = "q1_batch_driver.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.3.0"

%struct.SimpleBatch = type { %struct.SimpleColumnView*, i32, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }
%struct.Q1Stats = type { i64, i64, i32 }

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @q1_batch_driver_jit(%struct.SimpleBatch* noundef readonly %0, i32* noundef %1) local_unnamed_addr #0 {
  %3 = icmp ne %struct.SimpleBatch* %0, null
  %4 = icmp ne i32* %1, null
  %5 = and i1 %3, %4
  br i1 %5, label %6, label %19

6:                                                ; preds = %2
  %7 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 1
  %8 = load i32, i32* %7, align 8, !tbaa !10
  %9 = icmp slt i32 %8, 11
  br i1 %9, label %19, label %10

10:                                               ; preds = %6
  %11 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 0
  %12 = load %struct.SimpleColumnView*, %struct.SimpleColumnView** %11, align 8, !tbaa !17
  %13 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %12, i64 10, i32 4
  %14 = load i32, i32* %13, align 8, !tbaa !18
  %15 = icmp eq i32 %14, 7
  br i1 %15, label %16, label %19

16:                                               ; preds = %10
  %17 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %12, i64 10
  %18 = tail call i32 @filter_le_date32(%struct.SimpleColumnView* noundef nonnull %17, i32 noundef 10561, i32* noundef nonnull %1) #3
  br label %19

19:                                               ; preds = %16, %10, %2, %6
  %20 = phi i32 [ -1, %6 ], [ -1, %2 ], [ %18, %16 ], [ -1, %10 ]
  ret i32 %20
}

declare i32 @filter_le_date32(%struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #1

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind ssp willreturn uwtable(sync)
define void @q1_process_batch_jit(%struct.SimpleBatch* noundef readonly %0, i32* nocapture noundef readnone %1, i32 noundef %2, %struct.Q1Stats* noundef %3) local_unnamed_addr #2 {
  %5 = icmp ne %struct.SimpleBatch* %0, null
  %6 = icmp ne %struct.Q1Stats* %3, null
  %7 = and i1 %5, %6
  br i1 %7, label %8, label %21

8:                                                ; preds = %4
  %9 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 2
  %10 = load i64, i64* %9, align 8, !tbaa !20
  %11 = getelementptr inbounds %struct.Q1Stats, %struct.Q1Stats* %3, i64 0, i32 0
  %12 = load i64, i64* %11, align 8, !tbaa !21
  %13 = add nsw i64 %12, %10
  store i64 %13, i64* %11, align 8, !tbaa !21
  %14 = sext i32 %2 to i64
  %15 = getelementptr inbounds %struct.Q1Stats, %struct.Q1Stats* %3, i64 0, i32 1
  %16 = load i64, i64* %15, align 8, !tbaa !23
  %17 = add nsw i64 %16, %14
  store i64 %17, i64* %15, align 8, !tbaa !23
  %18 = getelementptr inbounds %struct.Q1Stats, %struct.Q1Stats* %3, i64 0, i32 2
  %19 = load i32, i32* %18, align 8, !tbaa !24
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %18, align 8, !tbaa !24
  br label %21

21:                                               ; preds = %4, %8
  ret void
}

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #2 = { argmemonly mustprogress nofree norecurse nosync nounwind ssp willreturn uwtable(sync) "frame-pointer"="non-leaf" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+crc,+crypto,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+lse,+neon,+ras,+rcpc,+rdm,+sha2,+sha3,+sm4,+v8.5a,+zcm,+zcz" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 13, i32 3]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"branch-target-enforcement", i32 0}
!3 = !{i32 8, !"sign-return-address", i32 0}
!4 = !{i32 8, !"sign-return-address-all", i32 0}
!5 = !{i32 8, !"sign-return-address-with-bkey", i32 0}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{i32 7, !"uwtable", i32 1}
!8 = !{i32 7, !"frame-pointer", i32 1}
!9 = !{!"Apple clang version 14.0.3 (clang-1403.0.22.14.1)"}
!10 = !{!11, !15, i64 8}
!11 = !{!"", !12, i64 0, !15, i64 8, !16, i64 16}
!12 = !{!"any pointer", !13, i64 0}
!13 = !{!"omnipotent char", !14, i64 0}
!14 = !{!"Simple C/C++ TBAA"}
!15 = !{!"int", !13, i64 0}
!16 = !{!"long long", !13, i64 0}
!17 = !{!11, !12, i64 0}
!18 = !{!19, !15, i64 32}
!19 = !{!"", !12, i64 0, !12, i64 8, !16, i64 16, !16, i64 24, !15, i64 32}
!20 = !{!11, !16, i64 16}
!21 = !{!22, !16, i64 0}
!22 = !{!"", !16, i64 0, !16, i64 8, !15, i64 16}
!23 = !{!22, !16, i64 8}
!24 = !{!22, !15, i64 16}

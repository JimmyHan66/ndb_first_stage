; ModuleID = 'q6_batch_driver.c'
source_filename = "q6_batch_driver.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.3.0"

%struct.SimpleBatch = type { %struct.SimpleColumnView*, i32, i64 }
%struct.SimpleColumnView = type { i32*, i8*, i64, i64, i32 }
%struct.Q6Stats = type { i64, i64, i32, i64, i64, i64, i64 }

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @q6_batch_driver_jit(%struct.SimpleBatch* noundef readonly %0, i32* noundef %1, i32* noundef %2, i32* noundef %3, i32* noundef %4) local_unnamed_addr #0 {
  %6 = icmp ne %struct.SimpleBatch* %0, null
  %7 = icmp ne i32* %1, null
  %8 = and i1 %6, %7
  br i1 %8, label %9, label %45

9:                                                ; preds = %5
  %10 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 1
  %11 = load i32, i32* %10, align 8, !tbaa !10
  %12 = icmp slt i32 %11, 16
  br i1 %12, label %45, label %13

13:                                               ; preds = %9
  %14 = icmp ne i32* %2, null
  %15 = icmp ne i32* %3, null
  %16 = and i1 %14, %15
  %17 = icmp ne i32* %4, null
  %18 = and i1 %16, %17
  br i1 %18, label %19, label %45

19:                                               ; preds = %13
  %20 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 0
  %21 = load %struct.SimpleColumnView*, %struct.SimpleColumnView** %20, align 8, !tbaa !17
  %22 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 10
  %23 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 6
  %24 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 4
  %25 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 10, i32 4
  %26 = load i32, i32* %25, align 8, !tbaa !18
  %27 = icmp eq i32 %26, 7
  br i1 %27, label %28, label %45

28:                                               ; preds = %19
  %29 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 6, i32 4
  %30 = load i32, i32* %29, align 8, !tbaa !18
  switch i32 %30, label %45 [
    i32 3, label %31
    i32 9, label %31
  ]

31:                                               ; preds = %28, %28
  %32 = getelementptr inbounds %struct.SimpleColumnView, %struct.SimpleColumnView* %21, i64 4, i32 4
  %33 = load i32, i32* %32, align 8, !tbaa !18
  switch i32 %33, label %45 [
    i32 3, label %34
    i32 9, label %34
  ]

34:                                               ; preds = %31, %31
  %35 = tail call i32 @filter_ge_date32(%struct.SimpleColumnView* noundef nonnull %22, i32 noundef 8766, i32* noundef nonnull %2) #3
  %36 = icmp slt i32 %35, 1
  br i1 %36, label %45, label %37

37:                                               ; preds = %34
  %38 = tail call i32 @filter_lt_date32_on_sel(i32* noundef nonnull %2, i32 noundef %35, %struct.SimpleColumnView* noundef nonnull %22, i32 noundef 9131, i32* noundef nonnull %3) #3
  %39 = icmp slt i32 %38, 1
  br i1 %39, label %45, label %40

40:                                               ; preds = %37
  %41 = tail call i32 @filter_between_i64_on_sel(i32* noundef nonnull %3, i32 noundef %38, %struct.SimpleColumnView* noundef nonnull %23, i64 noundef 5, i64 noundef 7, i32* noundef nonnull %4) #3
  %42 = icmp slt i32 %41, 1
  br i1 %42, label %45, label %43

43:                                               ; preds = %40
  %44 = tail call i32 @filter_lt_i64_on_sel(i32* noundef nonnull %4, i32 noundef %41, %struct.SimpleColumnView* noundef nonnull %24, i64 noundef 2400, i32* noundef nonnull %1) #3
  br label %45

45:                                               ; preds = %31, %28, %19, %37, %40, %43, %34, %13, %5, %9
  %46 = phi i32 [ -1, %9 ], [ -1, %5 ], [ -1, %13 ], [ -1, %31 ], [ -1, %28 ], [ -1, %19 ], [ %35, %34 ], [ %38, %37 ], [ %44, %43 ], [ %41, %40 ]
  ret i32 %46
}

declare i32 @filter_ge_date32(%struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #1

declare i32 @filter_lt_date32_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i32 noundef, i32* noundef) local_unnamed_addr #1

declare i32 @filter_between_i64_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i64 noundef, i64 noundef, i32* noundef) local_unnamed_addr #1

declare i32 @filter_lt_i64_on_sel(i32* noundef, i32 noundef, %struct.SimpleColumnView* noundef, i64 noundef, i32* noundef) local_unnamed_addr #1

; Function Attrs: argmemonly mustprogress nofree norecurse nosync nounwind ssp willreturn uwtable(sync)
define void @q6_process_batch_jit(%struct.SimpleBatch* noundef readonly %0, i32* nocapture noundef readnone %1, i32 noundef %2, %struct.Q6Stats* noundef %3) local_unnamed_addr #2 {
  %5 = icmp ne %struct.SimpleBatch* %0, null
  %6 = icmp ne %struct.Q6Stats* %3, null
  %7 = and i1 %5, %6
  br i1 %7, label %8, label %24

8:                                                ; preds = %4
  %9 = getelementptr inbounds %struct.SimpleBatch, %struct.SimpleBatch* %0, i64 0, i32 2
  %10 = load i64, i64* %9, align 8, !tbaa !20
  %11 = getelementptr inbounds %struct.Q6Stats, %struct.Q6Stats* %3, i64 0, i32 0
  %12 = load i64, i64* %11, align 8, !tbaa !21
  %13 = add nsw i64 %12, %10
  store i64 %13, i64* %11, align 8, !tbaa !21
  %14 = sext i32 %2 to i64
  %15 = getelementptr inbounds %struct.Q6Stats, %struct.Q6Stats* %3, i64 0, i32 1
  %16 = load i64, i64* %15, align 8, !tbaa !23
  %17 = add nsw i64 %16, %14
  store i64 %17, i64* %15, align 8, !tbaa !23
  %18 = getelementptr inbounds %struct.Q6Stats, %struct.Q6Stats* %3, i64 0, i32 2
  %19 = load i32, i32* %18, align 8, !tbaa !24
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %18, align 8, !tbaa !24
  %21 = getelementptr inbounds %struct.Q6Stats, %struct.Q6Stats* %3, i64 0, i32 6
  %22 = load i64, i64* %21, align 8, !tbaa !25
  %23 = add nsw i64 %22, %14
  store i64 %23, i64* %21, align 8, !tbaa !25
  br label %24

24:                                               ; preds = %4, %8
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
!22 = !{!"", !16, i64 0, !16, i64 8, !15, i64 16, !16, i64 24, !16, i64 32, !16, i64 40, !16, i64 48}
!23 = !{!22, !16, i64 8}
!24 = !{!22, !15, i64 16}
!25 = !{!22, !16, i64 48}

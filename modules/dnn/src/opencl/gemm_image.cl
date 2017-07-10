#ifndef __OPENCL_VERSION__
#define __kernel
#define __global
#define __constant
#define __local
#define get_global_id(x) 0
#define get_global_size(x) 0
#define get_local_id(x) 0
#define get_local_size(x) 0
#define FLT_MAX 0
#define FLT_MIN 0
#define cl_khr_fp64
#define cl_amd_fp64
#ifndef DISABLE_DOUBLE_SUPPORT
#define DOUBLE_SUPPORT_AVAILABLE
#endif //DISABLE_DOUBLE_SUPPORT
#define CLK_LOCAL_MEM_FENCE
#define CLK_GLOBAL_MEM_FENCE
#define Dtype float
#define barrier(x)
#define atomic_cmpxchg(x, y, z) x
#define signbit(x) x
#define int_tp long
#define uint_tp unsigned long
#define int_tpc long
#define uint_tpc unsigned long
#endif

#define CONCAT(A,B) A##_##B
#define TEMPLATE(name,type) CONCAT(name,type)

#define TYPE_FLOAT 1
#define TYPE_DOUBLE 2

#if defined(cl_khr_fp64)
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#ifndef DISABLE_DOUBLE_SUPPORT
#define DOUBLE_SUPPORT_AVAILABLE
#endif //DISABLE_DOUBLE_SUPPORT
#elif defined(cl_amd_fp64)
#pragma OPENCL EXTENSION cl_amd_fp64 : enable
#ifndef DISABLE_DOUBLE_SUPPORT
#define DOUBLE_SUPPORT_AVAILABLE
#endif //DISABLE_DOUBLE_SUPPORT
#endif

#if defined(cl_khr_int64_base_atomics)
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#define ATOMICS_64_AVAILABLE
#endif

#if defined(cl_khr_int32_base_atomics)
#pragma OPENCL EXTENSION cl_khr_int32_base_atomics : enable
#define ATOMICS_32_AVAILABLE
#endif

#if defined(cl_khr_global_int32_base_atomics)
#pragma OPENCL EXTENSION cl_khr_global_int32_base_atomics : enable
#define ATOMICS_32_AVAILABLE
#endif

// Types used for parameters, offset computations and so on
#define int_tp int
#define uint_tp unsigned int

// Definitions used to cast the types above as needed
#define int_tpc int
#define uint_tpc unsigned int

#define Dtype float
#define Dtype4 float4

#if defined(cl_intel_subgroups)
#pragma OPENCL EXTENSION  cl_intel_subgroups : enable
#endif

#define TILE_M          32
#define TILE_K          8
#define TILE_N          8

// common block to calculate (alpha * AxB + beta * C) and output to destination image.

//#define USE_IMAGE_C
#ifdef USE_IMAGE_C
#define BLOCKC_READ8( _C, _coordC ) as_float8( intel_sub_group_block_read8( _C, _coordC ) )
#define BLOCKC_WRITE8( _C, _coordC, _val ) intel_sub_group_block_write8( _C, _coordC, as_uint8( _val ) )
#define MATC_PARAMETER __read_only image2d_t C, __write_only image2d_t dst
#define GEMM_OUTPUT(ALPHA1, BETA_NOT0) GEMM_OUTPUT_EXT(ALPHA1, BETA_NOT0, C, dst, sizeof(uint))
#else
#define BLOCKC_READ8( _C, _coordC ) \
          (float8) ( (_coordC.x + get_local_id(0) < N && _coordC.y < M) ? _C[ _coordC.y * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 1 < M) ? _C[ ( _coordC.y + 1 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 2 < M) ? _C[ ( _coordC.y + 2 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 3 < M) ? _C[ ( _coordC.y + 3 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 4 < M) ? _C[ ( _coordC.y + 4 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 5 < M) ? _C[ ( _coordC.y + 5 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 6 < M) ? _C[ ( _coordC.y + 6 ) * N + _coordC.x + get_local_id(0) ] : 0, \
                     (_coordC.x + get_local_id(0) < N && _coordC.y + 7 < M) ? _C[ ( _coordC.y + 7 ) * N + _coordC.x + get_local_id(0) ] : 0)

#define BLOCKC_WRITE8( _C, _coordC, _val) do {\
                     if (_coordC.x + get_local_id(0) < N) { \
                       if (_coordC.y < M) \
                         _C[ _coordC.y * N + _coordC.x + get_local_id(0) ] = _val.s0; \
                       if (_coordC.y + 1 < M) \
                         _C[ ( _coordC.y + 1 )* N + _coordC.x + get_local_id(0) ] = _val.s1; \
                       if (_coordC.y + 2 < M) \
                         _C[ ( _coordC.y + 2 )* N + _coordC.x + get_local_id(0) ] = _val.s2; \
                       if (_coordC.y + 3 < M) \
                         _C[ ( _coordC.y + 3 )* N + _coordC.x + get_local_id(0) ] = _val.s3; \
                       if (_coordC.y + 4 < M) \
                         _C[ ( _coordC.y + 4 )* N + _coordC.x + get_local_id(0) ] = _val.s4; \
                       if (_coordC.y + 5 < M) \
                         _C[ ( _coordC.y + 5 )* N + _coordC.x + get_local_id(0) ] = _val.s5; \
                       if (_coordC.y + 6 < M) \
                         _C[ ( _coordC.y + 6 )* N + _coordC.x + get_local_id(0) ] = _val.s6; \
                       if (_coordC.y + 7 < M) \
                         _C[ ( _coordC.y + 7 )* N + _coordC.x + get_local_id(0) ] = _val.s7; \
                     }} while(0)
#define MATC_PARAMETER __global Dtype * C, const int offC, const int M, const int N
#define GEMM_OUTPUT(ALPHA1, BETA_NOT0) GEMM_OUTPUT_EXT(ALPHA1, BETA_NOT0, (C + offC), (C + offC), 1)
#endif

#define GEMM_OUTPUT_EXT(ALPHA1, BETA_NOT0, _C, _dst, _C_step) \
    int2    coordDst = (int2)( ( group_x * TILE_N ) * _C_step, ( group_y * TILE_M ) ); \
    int2    coordC = coordDst; \
    float8 blockC00; \
    float8 blockC01; \
    float8 blockC02; \
    float8 blockC03; \
    if (BETA_NOT0) { \
        blockC00 = BLOCKC_READ8( _C, coordC );    coordC.y += 8; \
        blockC01 = BLOCKC_READ8( _C, coordC );    coordC.y += 8; \
        blockC02 = BLOCKC_READ8( _C, coordC );    coordC.y += 8; \
        blockC03 = BLOCKC_READ8( _C, coordC ); \
        if (!ALPHA1) { \
            blockC00 *= beta; \
            blockC01 *= beta; \
            blockC02 *= beta; \
            blockC03 *= beta; \
            blockC00 = mad(blockAxB00, (float8)alpha, blockC00); \
            blockC01 = mad(blockAxB01, (float8)alpha, blockC01); \
            blockC02 = mad(blockAxB02, (float8)alpha, blockC02); \
            blockC03 = mad(blockAxB03, (float8)alpha, blockC03); \
        } else { \
            blockC00 = mad(blockC00, (float8)beta, blockAxB00); \
            blockC01 = mad(blockC01, (float8)beta, blockAxB01); \
            blockC02 = mad(blockC02, (float8)beta, blockAxB02); \
            blockC03 = mad(blockC03, (float8)beta, blockAxB03); \
        } \
    } else { \
        if (!ALPHA1) { \
          blockC00 = blockAxB00 * alpha; \
          blockC01 = blockAxB01 * alpha; \
          blockC02 = blockAxB02 * alpha; \
          blockC03 = blockAxB03 * alpha; \
        } else { \
          blockC00 = blockAxB00; \
          blockC01 = blockAxB01; \
          blockC02 = blockAxB02; \
          blockC03 = blockAxB03; \
        } \
    } \
    BLOCKC_WRITE8( _dst, coordDst, blockC00 );    coordDst.y += 8; \
    BLOCKC_WRITE8( _dst, coordDst, blockC01 );    coordDst.y += 8; \
    BLOCKC_WRITE8( _dst, coordDst, blockC02 );    coordDst.y += 8; \
    BLOCKC_WRITE8( _dst, coordDst, blockC03 );

// Get the specified column of the block of the block
#define TRANSPOSE_BLOCK_8( _block, _col )   \
        (float8)( intel_sub_group_shuffle( _block.s0, _col ),   \
                  intel_sub_group_shuffle( _block.s1, _col ),   \
                  intel_sub_group_shuffle( _block.s2, _col ),   \
                  intel_sub_group_shuffle( _block.s3, _col ),   \
                  intel_sub_group_shuffle( _block.s4, _col ),   \
                  intel_sub_group_shuffle( _block.s5, _col ),   \
                  intel_sub_group_shuffle( _block.s6, _col ),   \
                  intel_sub_group_shuffle( _block.s7, _col ) );

// A's column block multiply B 's row block.
#define MULTIPLY_BLOCKS_8x8( _result, _blockA, _blockB )    \
        {   \
            const float8    acol0 = TRANSPOSE_BLOCK_8( _blockA, 0 );    \
            const float8    acol1 = TRANSPOSE_BLOCK_8( _blockA, 1 );    \
            const float8    acol2 = TRANSPOSE_BLOCK_8( _blockA, 2 );    \
            const float8    acol3 = TRANSPOSE_BLOCK_8( _blockA, 3 );    \
            const float8    acol4 = TRANSPOSE_BLOCK_8( _blockA, 4 );    \
            const float8    acol5 = TRANSPOSE_BLOCK_8( _blockA, 5 );    \
            const float8    acol6 = TRANSPOSE_BLOCK_8( _blockA, 6 );    \
            const float8    acol7 = TRANSPOSE_BLOCK_8( _blockA, 7 );    \
            _result = mad( (float8)(_blockB.s0), acol0, _result );      \
            _result = mad( (float8)(_blockB.s1), acol1, _result );      \
            _result = mad( (float8)(_blockB.s2), acol2, _result );      \
            _result = mad( (float8)(_blockB.s3), acol3, _result );      \
            _result = mad( (float8)(_blockB.s4), acol4, _result );      \
            _result = mad( (float8)(_blockB.s5), acol5, _result );      \
            _result = mad( (float8)(_blockB.s6), acol6, _result );      \
            _result = mad( (float8)(_blockB.s7), acol7, _result );      \
        }

#define GEMM_NN(ALPHA1, BETA_NOT0) \
__attribute__((reqd_work_group_size(8, 1, 1))) \
__kernel void TEMPLATE(gemm_32_1_NN_ ##ALPHA1 ##_ ##BETA_NOT0,Dtype)( \
    __read_only image2d_t A, \
    __read_only image2d_t B, \
    MATC_PARAMETER, \
    float alpha, \
    float beta, \
    int width0) \
{ \
    const int group_x = get_group_id(0); \
    const int group_y = get_group_id(1); \
    float8 blockAxB00 = 0.0f; \
    float8 blockAxB01 = 0.0f; \
    float8 blockAxB02 = 0.0f; \
    float8 blockAxB03 = 0.0f; \
    int2    coordA = (int2)( 0, group_y * TILE_M ); \
    int2    coordB = (int2)( ( group_x * TILE_N ) * sizeof(uint), 0 ); \
    do \
    {  \
        int2    coordBTemp = coordB; \
        float8  blockB00 = as_float8( intel_sub_group_block_read8( B, coordBTemp ) );    coordB.y += TILE_K; \
        int2    coordATemp = coordA; \
        float8  blockA00 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8  blockA01 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8  blockA02 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8  blockA03 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordA.x += TILE_K * sizeof(uint); \
        MULTIPLY_BLOCKS_8x8( blockAxB00, blockA00, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB01, blockA01, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB02, blockA02, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB03, blockA03, blockB00 ); \
    } \
    while( coordB.y < width0 ); \
    GEMM_OUTPUT(ALPHA1, BETA_NOT0); \
}

GEMM_NN(1, 0) // ALPHA == 1, BETA == 0
GEMM_NN(1, 1) // ALPHA == 1, BETA != 0
GEMM_NN(0, 0) // ALPHA != 1, BETA == 0
GEMM_NN(0, 1) // ALPHA != 1, BETA != 0

#undef TRANSPOSE_BLOCK_8
#undef MULTIPLY_BLOCKS_8x8

// replicate the first row to column block.
#define TRANSPOSE_BLOCK_8(_vec) \
        (float8)( intel_sub_group_shuffle(_vec, 0), \
                  intel_sub_group_shuffle(_vec, 1), \
                  intel_sub_group_shuffle(_vec, 2), \
                  intel_sub_group_shuffle(_vec, 3), \
                  intel_sub_group_shuffle(_vec, 4), \
                  intel_sub_group_shuffle(_vec, 5), \
                  intel_sub_group_shuffle(_vec, 6), \
                  intel_sub_group_shuffle(_vec, 7) )

#define MULTIPLY_BLOCKS_8x8( _result, _blockA, _blockB )    \
        {   \
            _result = mad( (float8)(_blockB.s0), TRANSPOSE_BLOCK_8(_blockA.s0), _result );      \
            _result = mad( (float8)(_blockB.s1), TRANSPOSE_BLOCK_8(_blockA.s1), _result );      \
            _result = mad( (float8)(_blockB.s2), TRANSPOSE_BLOCK_8(_blockA.s2), _result );      \
            _result = mad( (float8)(_blockB.s3), TRANSPOSE_BLOCK_8(_blockA.s3), _result );      \
            _result = mad( (float8)(_blockB.s4), TRANSPOSE_BLOCK_8(_blockA.s4), _result );      \
            _result = mad( (float8)(_blockB.s5), TRANSPOSE_BLOCK_8(_blockA.s5), _result );      \
            _result = mad( (float8)(_blockB.s6), TRANSPOSE_BLOCK_8(_blockA.s6), _result );      \
            _result = mad( (float8)(_blockB.s7), TRANSPOSE_BLOCK_8(_blockA.s7), _result );      \
        }

#define GEMM_TN(ALPHA1, BETA_NOT0) \
__attribute__((reqd_work_group_size(8, 1, 1))) \
__kernel void TEMPLATE(gemm_32_1_TN_ ##ALPHA1 ##_ ##BETA_NOT0,Dtype)( \
    __read_only image2d_t A, \
    __read_only image2d_t B, \
    MATC_PARAMETER, \
    float alpha, \
    float beta, \
    int width0) \
{ \
    const int group_x = get_group_id(0);\
    const int group_y = get_group_id(1);\
    float8 blockAxB00 = 0.0f;\
    float8 blockAxB01 = 0.0f;\
    float8 blockAxB02 = 0.0f;\
    float8 blockAxB03 = 0.0f;\
    int2    coordA = (int2)( group_y * TILE_M * sizeof(uint), 0 );\
    int2    coordB = (int2)( ( group_x * TILE_N ) * sizeof(uint), 0 );\
    do\
    {\
        int2    coordBTemp = coordB;\
        float8 blockB00 = as_float8( intel_sub_group_block_read8( B, coordBTemp ) );    coordB.y += TILE_K;\
        int2    coordATemp = coordA;\
        float8 blockA00 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint);\
        float8 blockA01 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint);\
        float8 blockA02 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint);\
        float8 blockA03 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordA.y += TILE_K;\
        MULTIPLY_BLOCKS_8x8( blockAxB00, blockA00, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB01, blockA01, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB02, blockA02, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB03, blockA03, blockB00 ); \
    } \
    while( coordB.y < width0 ); \
    GEMM_OUTPUT(ALPHA1, BETA_NOT0); \
}

GEMM_TN(1, 0) // ALPHA == 1, BETA == 0
GEMM_TN(1, 1) // ALPHA == 1, BETA != 0
GEMM_TN(0, 0) // ALPHA != 1, BETA == 0
GEMM_TN(0, 1) // ALPHA != 1, BETA != 0

#undef MULTIPLY_BLOCKS_8x8
#undef TRANSPOSE_BLOCK_8

// The same as GEMM_NN
#define TRANSPOSE_BLOCK_8( _block, _col )   \
        (float8)( intel_sub_group_shuffle( _block.s0, _col),   \
                  intel_sub_group_shuffle( _block.s1, _col),   \
                  intel_sub_group_shuffle( _block.s2, _col),   \
                  intel_sub_group_shuffle( _block.s3, _col),   \
                  intel_sub_group_shuffle( _block.s4, _col),   \
                  intel_sub_group_shuffle( _block.s5, _col),   \
                  intel_sub_group_shuffle( _block.s6, _col),   \
                  intel_sub_group_shuffle( _block.s7, _col) )

#define MULTIPLY_BLOCKS_8x8( _result, _blockA, _blockB )    \
        {   \
            const float8    acol0 = TRANSPOSE_BLOCK_8( _blockA, 0 );    \
            const float8    acol1 = TRANSPOSE_BLOCK_8( _blockA, 1 );    \
            const float8    acol2 = TRANSPOSE_BLOCK_8( _blockA, 2 );    \
            const float8    acol3 = TRANSPOSE_BLOCK_8( _blockA, 3 );    \
            const float8    acol4 = TRANSPOSE_BLOCK_8( _blockA, 4 );    \
            const float8    acol5 = TRANSPOSE_BLOCK_8( _blockA, 5 );    \
            const float8    acol6 = TRANSPOSE_BLOCK_8( _blockA, 6 );    \
            const float8    acol7 = TRANSPOSE_BLOCK_8( _blockA, 7 );    \
            _result = mad( (float8)_blockB.s0, acol0, _result );      \
            _result = mad( (float8)_blockB.s1, acol1, _result );      \
            _result = mad( (float8)_blockB.s2, acol2, _result );      \
            _result = mad( (float8)_blockB.s3, acol3, _result );      \
            _result = mad( (float8)_blockB.s4, acol4, _result );      \
            _result = mad( (float8)_blockB.s5, acol5, _result );      \
            _result = mad( (float8)_blockB.s6, acol6, _result );      \
            _result = mad( (float8)_blockB.s7, acol7, _result );      \
        }



#define GEMM_NT(ALPHA1, BETA_NOT0, VECSCALAR, VECSIZE) \
__attribute__((reqd_work_group_size(8, 1, 1))) \
__kernel void TEMPLATE(gemm_32_1_NT_ ##VECSCALAR ##_ ##ALPHA1 ##_ ##BETA_NOT0,Dtype)( \
    __read_only image2d_t A, \
    MATB_PARAMETER, \
    MATC_PARAMETER, \
    float alpha, \
    float beta, \
    int padded_k, \
    int k) \
{ \
    const int group_x = get_group_id(0); \
    const int group_y = get_group_id(1); \
    float8 blockAxB00 = 0.0f; \
    float8 blockAxB01 = 0.0f; \
    float8 blockAxB02 = 0.0f; \
    float8 blockAxB03 = 0.0f; \
    int2    coordA = (int2)( 0, group_y * TILE_M ); \
    int2    coordB = (int2)( 0, ( group_x * TILE_N )); \
    const sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST; \
    do \
    { \
        float8 blockB00;             \
        BLOCKB_READ8(blockB00, B, coordB); \
        int2    coordATemp = coordA; \
        float8 blockA00 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8 blockA01 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8 blockA02 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.y += 8; \
        float8 blockA03 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordA.x += TILE_K * sizeof(uint); \
        MULTIPLY_BLOCKS_8x8( blockAxB00, blockA00, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB01, blockA01, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB02, blockA02, blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB03, blockA03, blockB00 ); \
    } \
    while( coordB.x < padded_k / VECSIZE ); \
    GEMM_OUTPUT(ALPHA1, BETA_NOT0); \
}


#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        _blockb.s0123 = read_imagef(_B, sampler, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s4567 = read_imagef(_B, sampler, _coordBTemp); _coordB.x += 2;

#define MATB_PARAMETER __read_only image2d_t B

GEMM_NT(1, 0, VEC4, 4) // ALPHA == 1, BETA == 0
GEMM_NT(1, 1, VEC4, 4) // ALPHA == 1, BETA != 0
GEMM_NT(0, 0, VEC4, 4) // ALPHA != 1, BETA == 0
GEMM_NT(0, 1, VEC4, 4) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER

#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        _blockb = *(__global float8*)&_B[_coordBTemp.y * k + _coordBTemp.x + offB];\
        _coordB.x += TILE_K;

#define MATB_PARAMETER __global float *B, int offB

GEMM_NT(1, 0, BUFFER, 1) // ALPHA == 1, BETA == 0
GEMM_NT(1, 1, BUFFER, 1) // ALPHA == 1, BETA != 0
GEMM_NT(0, 0, BUFFER, 1) // ALPHA != 1, BETA == 0
GEMM_NT(0, 1, BUFFER, 1) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER


#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        float4 temp; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s0 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s1 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s2 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s3 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s4 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s5 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s6 = temp.s0; \
        temp = read_imagef(_B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s7 = temp.s0; \
        _coordB.x += 8;

#define MATB_PARAMETER __read_only image2d_t B

GEMM_NT(1, 0, SCALAR, 1) // ALPHA == 1, BETA == 0
GEMM_NT(1, 1, SCALAR, 1) // ALPHA == 1, BETA != 0
GEMM_NT(0, 0, SCALAR, 1) // ALPHA != 1, BETA == 0
GEMM_NT(0, 1, SCALAR, 1) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER

#undef MULTIPLY_BLOCKS_8x8
#undef TRANSPOSE_BLOCK_8

//The same as GEMM_TN.
#define TRANSPOSE_BLOCK_8(_vec) \
        (float8)( intel_sub_group_shuffle(_vec, 0), \
                  intel_sub_group_shuffle(_vec, 1), \
                  intel_sub_group_shuffle(_vec, 2), \
                  intel_sub_group_shuffle(_vec, 3), \
                  intel_sub_group_shuffle(_vec, 4), \
                  intel_sub_group_shuffle(_vec, 5), \
                  intel_sub_group_shuffle(_vec, 6), \
                  intel_sub_group_shuffle(_vec, 7) );

#define MULTIPLY_BLOCKS_8x8( _result, _blockA, _blockB )    \
        {   \
            const float8    acol0 = TRANSPOSE_BLOCK_8( _blockA.s0 );    \
            const float8    acol1 = TRANSPOSE_BLOCK_8( _blockA.s1 );    \
            const float8    acol2 = TRANSPOSE_BLOCK_8( _blockA.s2 );    \
            const float8    acol3 = TRANSPOSE_BLOCK_8( _blockA.s3 );    \
            const float8    acol4 = TRANSPOSE_BLOCK_8( _blockA.s4 );    \
            const float8    acol5 = TRANSPOSE_BLOCK_8( _blockA.s5 );    \
            const float8    acol6 = TRANSPOSE_BLOCK_8( _blockA.s6 );    \
            const float8    acol7 = TRANSPOSE_BLOCK_8( _blockA.s7 );    \
            _result = mad( (float8)_blockB.s0, acol0, _result );      \
            _result = mad( (float8)_blockB.s1, acol1, _result );      \
            _result = mad( (float8)_blockB.s2, acol2, _result );      \
            _result = mad( (float8)_blockB.s3, acol3, _result );      \
            _result = mad( (float8)_blockB.s4, acol4, _result );      \
            _result = mad( (float8)_blockB.s5, acol5, _result );      \
            _result = mad( (float8)_blockB.s6, acol6, _result );      \
            _result = mad( (float8)_blockB.s7, acol7, _result );      \
        }

#define GEMM_TT(ALPHA1, BETA_NOT0, VECSCALAR, VECSIZE) \
__attribute__((reqd_work_group_size(8, 1, 1))) \
__kernel void TEMPLATE(gemm_32_1_TT_ ##VECSCALAR ##_ ##ALPHA1 ##_ ##BETA_NOT0, Dtype)( \
    __read_only image2d_t A, \
    MATB_PARAMETER, \
    MATC_PARAMETER, \
    float alpha, \
    float beta, \
    int padded_k, \
    int k) \
{ \
    const int group_x = get_group_id(0); \
    const int group_y = get_group_id(1); \
    float8 blockAxB00 = 0.0f; \
    float8 blockAxB01 = 0.0f; \
    float8 blockAxB02 = 0.0f; \
    float8 blockAxB03 = 0.0f; \
    int2    coordA = (int2)( group_y * TILE_M * sizeof(uint), 0 ); \
    int2    coordB = (int2)( 0, ( group_x * TILE_N )); \
    const sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST; \
    do \
    { \
        float8 blockB00;             \
        BLOCKB_READ8(blockB00, B, coordB); \
        int2    coordATemp = coordA; \
        float8 blockA00 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint); \
        float8 blockA01 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint); \
        float8 blockA02 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordATemp.x += 8 * sizeof(uint); \
        float8 blockA03 = as_float8( intel_sub_group_block_read8( A, coordATemp ) );    coordA.y += TILE_K; \
        MULTIPLY_BLOCKS_8x8( blockAxB00, blockA00 , blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB01, blockA01 , blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB02, blockA02 , blockB00 ); \
        MULTIPLY_BLOCKS_8x8( blockAxB03, blockA03 , blockB00 ); \
    } \
    while( coordB.x < padded_k / VECSIZE ); \
    GEMM_OUTPUT(ALPHA1, BETA_NOT0);\
}

#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        blockB00.s0123 = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        blockB00.s4567 = read_imagef(B, _coordBTemp); _coordB.x += 2;

#define MATB_PARAMETER __read_only image2d_t B

GEMM_TT(1, 0, VEC4, 4) // ALPHA == 1, BETA == 0
GEMM_TT(1, 1, VEC4, 4) // ALPHA == 1, BETA != 0
GEMM_TT(0, 0, VEC4, 4) // ALPHA != 1, BETA == 0
GEMM_TT(0, 1, VEC4, 4) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER

#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        _blockb = *(__global float8*)&_B[_coordBTemp.y * k + _coordBTemp.x + offB];\
        _coordB.x += TILE_K;

#define MATB_PARAMETER __global float *B, int offB

GEMM_TT(1, 0, BUFFER, 1) // ALPHA == 1, BETA == 0
GEMM_TT(1, 1, BUFFER, 1) // ALPHA == 1, BETA != 0
GEMM_TT(0, 0, BUFFER, 1) // ALPHA != 1, BETA == 0
GEMM_TT(0, 1, BUFFER, 1) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER

#define BLOCKB_READ8(_blockb, _B, _coordB) \
        int2 _coordBTemp = _coordB; \
        _coordBTemp.y += get_local_id(0); \
        float4 temp; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s0 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s1 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s2 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s3 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s4 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s5 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s6 = temp.s0; \
        temp = read_imagef(B, _coordBTemp); _coordBTemp.x += 1; \
        _blockb.s7 = temp.s0; \
        _coordB.x += 8;

#define MATB_PARAMETER __read_only image2d_t B

GEMM_TT(1, 0, SCALAR, 1) // ALPHA == 1, BETA == 0
GEMM_TT(1, 1, SCALAR, 1) // ALPHA == 1, BETA != 0
GEMM_TT(0, 0, SCALAR, 1) // ALPHA != 1, BETA == 0
GEMM_TT(0, 1, SCALAR, 1) // ALPHA != 1, BETA != 0
#undef BLOCKB_READ8
#undef MATB_PARAMETER

#undef MULTIPLY_BLOCKS_8x8
#undef TRANSPOSE_BLOCK_8

#undef TILE_M
#undef TILE_K
#undef TILE_N

__kernel void TEMPLATE(gemm_buffer_copy_image,Dtype)(
    __global float* A,
    __write_only image2d_t ImA,
    int offA,
    int width,
    int height)
{
    const int gidx = get_global_id(0);
    const int gidy = get_global_id(1);
    int2 coord_dst = (int2)(gidx, gidy);
    if (gidx >= width || gidy >= height) {
      write_imageui(ImA, coord_dst, (uint4)0);
      return;
    }
    __global float* A_off = A + offA;
    uint4 srcA = convert_uint4(as_uchar4(A_off[gidy * width + gidx]));
    write_imageui(ImA, coord_dst, srcA);
}

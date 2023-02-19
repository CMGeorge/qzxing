#set(CMP0100 NEW)

SET(BIG_INT_SOURCES
     ${BIGINT_DIR}/BigInteger.hh
     ${BIGINT_DIR}/BigInteger.cc
     ${BIGINT_DIR}/BigIntegerAlgorithms.hh
     ${BIGINT_DIR}/BigIntegerAlgorithms.cc
     ${BIGINT_DIR}/BigIntegerLibrary.hh
     ${BIGINT_DIR}/BigIntegerUtils.hh
     ${BIGINT_DIR}/BigIntegerUtils.cc
     ${BIGINT_DIR}/BigUnsigned.hh
     ${BIGINT_DIR}/BigUnsigned.cc
     ${BIGINT_DIR}/BigUnsignedInABase.hh
     ${BIGINT_DIR}/BigUnsignedInABase.cc
     ${BIGINT_DIR}/NumberlikeArray.hh
    )
set_property(
    SOURCE
        ${BIG_INT_SOURCES}
    PROPERTY
        SKIP_AUTOMOC ON
)
target_sources(qzxing PRIVATE ${BIG_INT_SOURCES})
